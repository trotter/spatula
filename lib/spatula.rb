require 'rubygems'
require 'net/http'
require 'uri'
require 'json'

module Spatula
  BASE_URL = "http://cookbooks.opscode.com/api/v1"

  class Spatula
    @commands = {}

    def self.register(command, klass)
      @commands[command] = klass
    end

    def self.run
      command = ARGV.shift
      if klass = @commands[command]
        klass.run(*ARGV)
      else
        Spatula.new.send(command, *ARGV)
      end
    end

    # Show the cookbook named :name:
    def show(name)
      print_response(get_cookbook_info(name))
    end

    # Show the latest version of the cookbook named :name:
    def show_latest_version(name)
      print_response(get_version_info(name))
    end

    # Install the cookbook :name: into cwd/cookbooks
    #   Will create a cookbook_tarballs dir for storing downloaded tarballs
    def install(name)
      file = JSON.parse(get_version_info(name))["file"]
      filename = File.basename(file)
      FileUtils.mkdir_p("cookbook_tarballs")
      `curl #{file} -o cookbook_tarballs/#{filename}`
      `tar xzvf cookbook_tarballs/#{filename} -C cookbooks`
    end

    private
      def strict_system *cmd
        cmd.map! &:to_s
        result = []

        trace = cmd.join(' ')
        warn trace if $TRACE

        pid, inn, out, err = popen4(*cmd)

        inn.sync   = true
        streams    = [out, err]
        out_stream = {
          out => $stdout,
          err => $stderr,
        }

        out_stream_buffers = {
          out => "",
          err => ""
        }

        # Handle process termination ourselves
        status = nil
        Thread.start do
          status = Process.waitpid2(pid).last
        end

        until streams.empty? do
          # don't busy loop
          selected, = select streams, nil, nil, 0.1

          next if selected.nil? or selected.empty?

          selected.each do |stream|
            if stream.eof? then
              streams.delete stream if status # we've quit, so no more writing
              next
            end

            data = stream.readpartial(1024)
            out_stream[stream].write data
            out_stream_buffers[stream] << data

            if stream == err and out_stream_buffers[stream] =~ /password(?:for)?.*:/i then
              out_stream_buffers[stream] = ""
              inn.puts @password
              data << "\n"
              $stderr.write "\n"
            end

            result << data
          end
        end

        unless status.success? then
          raise "execution failed with status #{status.exitstatus}: #{cmd.join ' '}"
        end

        result.join
      ensure
        inn.close rescue nil
        out.close rescue nil
        err.close rescue nil
      end

      def get_cookbook_info(name)
        url = URI.parse("%s/cookbooks/%s" % [BASE_URL, name])
        Net::HTTP.get(url)
      end

      def get_version_info(name)
        latest = JSON.parse(get_cookbook_info(name))["latest_version"]
        response = Net::HTTP.get(URI.parse(latest))
      end

      def print_response(response)
        item = JSON.parse(response)
        item.each_pair do |k, v|
          puts "#{k}:\t#{v}"
        end
      end
  end
end

require 'spatula/search'
require 'spatula/prepare'
require 'spatula/cook'

if __FILE__ == $0
  Spatula::Spatula.run
end
