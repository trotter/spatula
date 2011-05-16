require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'thor'

module Spatula
  BASE_URL = "http://cookbooks.opscode.com/api/v1"

  class Spatula < Thor
    desc "show COOKBOOK", "Show information about a cookbook"
    def show(name)
      print_response(get_cookbook_info(name))
    end

    desc "show_latest_version COOKBOOK", "Show the latest version for a cookbook"
    def show_latest_version(name)
      print_response(get_version_info(name))
    end

    desc "install COOKBOOK", "Install the latest version of COOKBOOK into ./cookbooks"
    def install(name)
      file = JSON.parse(get_version_info(name))["file"]
      filename = File.basename(file)
      # Use ENV['HOME'] as the base here
      tarball_dir = "#{ENV['HOME']}/.spatula/cookbook_tarballs"
      FileUtils.mkdir_p(tarball_dir)
      system "curl #{file} -o #{tarball_dir}/#{filename}"
      system "tar xzvf #{tarball_dir}/#{filename} -C cookbooks"
    end

    desc "search QUERY", "Search cookbooks.opscode.com for cookbooks matching QUERY"
    method_options :start => 0, :count => 10
    def search(query)
      Search.run(query, options[:start], options[:count])
    end

    desc "cook SERVER NODE", "Cook SERVER with the specification in config/NODE.js. Use local as the server to cook this box."
    method_options :port => nil
    method_options :login    => nil
    method_options :identity => nil
    method_options :log_level => nil
    def cook(server, node)
      Cook.run(server, node, options[:port], options[:login], options[:identity], options[:log_level])
    end

    desc "prepare SERVER", "Install software/libs required by chef on SERVER"
    method_options :port     => nil
    method_options :login    => nil
    method_options :identity => nil
    method_options :upload_key => nil
    method_options :keyfile => :string
    method_options :ruby_version => :string
    def prepare(server)
      Prepare.run(server, options[:port], options[:login], options[:identity], options[:upload_key], options[:keyfile], options[:ruby_version])
    end

    private
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

if __FILE__ == $0
  $: << File.dirname(__FILE__)
end

require 'spatula/ssh_command'
require 'spatula/search'
require 'spatula/prepare'
require 'spatula/cook'

if __FILE__ == $0
  Spatula::Spatula.start
end
