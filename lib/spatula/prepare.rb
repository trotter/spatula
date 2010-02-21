# Prepare :server: for chef solo to run on it
module Spatula
  class Prepare
    Spatula.register("prepare", self)

    def self.run(*args)
      new(*args).run
    end

    def initialize(server, port=22)
      @server = server
      @port   = port
    end

    def run
      sh %Q|ssh -t -p #@port #@server sudo aptitude -y install ruby rubygems rubygems1.8 irb ri libopenssl-ruby1.8 libshadow-ruby1.8 ruby1.8-dev gcc g++ rsync |
      sh %Q|ssh -t -p #@port #@server sudo gem install rdoc chef ohai --no-ri --no-rdoc --source http://gems.opscode.com --source http://gems.rubyforge.org|
    end

    private
      def sh(command)
        stdout = `#{command}`
        puts stdout
        stdout
      end
  end
end
