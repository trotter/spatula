module Spatula
  # TODO: Set REMOTE_CHEF_PATH using value for file_cache_path
  REMOTE_CHEF_PATH = "/tmp/chef-solo" # Where to find upstream cookbooks

  class Cook
    def self.run(*args)
      new(*args).run
    end

    def initialize(server, node, port=nil)
      @server = server
      @node = node
      @port = port
    end

    def run
      Dir["**/*.rb"].each do |recipe|
        ok = sh "ruby -c #{recipe} >/dev/null 2>&1"
        raise "Syntax error in #{recipe}" if not ok
      end

      port_switch = @port ? " -p#@port" : ""
      sh "rsync -rlP --rsh=\"ssh#{port_switch}\" --delete --exclude '.*' ./ #@server:#{REMOTE_CHEF_PATH}"
      sh "ssh -t#{port_switch} -A #@server \"cd #{REMOTE_CHEF_PATH}; sudo chef-solo -c config/solo.rb -j config/#@node.json \""
    end

    private
      def sh(command)
        system command
      end
  end
end
