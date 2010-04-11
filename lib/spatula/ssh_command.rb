module Spatula
  class SshCommand
    def self.run(*args)
      new(*args).run
    end

    def initialize(server, port=nil, login=nil, identity=nil)
      @server = server
      @port   = port
      @port_switch = port ? " -p #{port}" : '' 
      @login_switch = login ? "-l #{login}" : ''
      @identity_switch = identity ? %Q|-i "#{identity}"| : ''
    end

    def ssh(command)
      sh ssh_command(command)
    end

    def ssh_command(command)
      %Q|ssh -t#{ssh_opts} #@server "#{command.gsub('"', '\\"')}"|
    end

    def ssh_opts
      "#@port_switch #@login_switch #@identity_switch"
    end

    private
      def sh(command)
        system command
      end
  end
end
