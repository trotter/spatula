module Spatula
  # TODO: Set REMOTE_CHEF_PATH using value for file_cache_path
  REMOTE_CHEF_PATH = "/tmp/chef-solo" # Where to find upstream cookbooks

  class Cook
    Spatula.register("cook", self)

    def self.run(*args)
      new(*args).run
    end

    def initialize(server, node, port=22)
      @server = server
      @node = node
      @port = port
    end

    def run
      sh "rake test"
      sh "rsync -rlP --rsh=\"ssh -p#@port\" --delete --exclude '.*' ./ #@server:#{REMOTE_CHEF_PATH}"
      sh "ssh -t -p #@port -A #@server \"cd #{REMOTE_CHEF_PATH}; sudo chef-solo -c config/solo.rb -j config/#@node.json \""
    end

    private
      def sh(command)
        system command
      end
  end
end
