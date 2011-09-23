# Prepare :server: for chef solo to run on it
module Spatula
  class Prepare < SshCommand
    DEFAULT_RUBY_VERSION = "1.9.2-p290"

    def run
      upload_ssh_key
      send "run_for_#{os}"
    end

    def os
      etc_issue = `#{ssh_command("cat /etc/issue")}`
      case etc_issue
      when /ubuntu/i then "apt"
      when /debian/i then "apt"
      when /fedora/i then "yum"
      when /CentOS/i then "yum"
      when ""
        raise "Couldn't get system info from /etc/issue. Please check your SSH credentials."
      else
        raise "Sorry, we currently only support prepare on ubuntu, debian & fedora. Please fork http://github.com/trotter/spatula and add support for your OS. I'm happy to incorporate pull requests."
      end
    end

    def run_for_apt
      ssh_sudo(
        "apt-get update",
        "apt-get install -y build-essential zlib1g-dev libssl-dev libreadline5-dev curl rsync git-core")
      install_ruby_build
      install_ruby
      install_chef
    end

    def run_for_yum
      ssh_sudo "yum install -y make gcc gcc-c++ rsync sudo openssl-devel curl git"
      install_ruby_build
      install_ruby
      install_chef
    end

    def ruby_version
      @ruby_version || DEFAULT_RUBY_VERSION
    end

    def ruby_path
      if ruby_version =~ /^\d/
        "/usr/local/ruby-#{ruby_version}"
      else
        "/usr/local/#{ruby_version}"
      end
    end

    def install_ruby_build
      ssh(
        "git clone git://github.com/sstephenson/ruby-build.git",
        "cd ruby-build && #{sudo} ./install.sh")
    end

    def install_ruby
      ssh_sudo(
        "/usr/local/bin/ruby-build #{ruby_version} #{ruby_path}",
        "ln -fs #{ruby_path} /usr/local/ruby",
        %Q{echo "PATH=$PATH:/usr/local/ruby/bin" > ruby_path.sh && sudo cp ruby_path.sh /etc/profile.d/})
    end

    def install_chef
      ssh_sudo "#{ruby_path}/bin/gem install chef --no-ri --no-rdoc"
    end

    def upload_ssh_key
      authorized_file = "~/.ssh/authorized_keys"

      unless @key_file
        %w{rsa dsa}.each do |key_type|
          filename = "#{ENV['HOME']}/.ssh/id_#{key_type}.pub"
          if File.exists?(filename)
            @key_file = filename
            break
          end
        end
      end

      raise "Key file '#{@key_file}' not found: aborting." unless File.exists?(@key_file)

      key = File.open(@key_file).read.split(' ')[0..1].join(' ')

      ssh "mkdir -p .ssh && echo #{key} >> #{authorized_file}"
      ssh "cat #{authorized_file} | sort | uniq > #{authorized_file}.tmp && mv #{authorized_file}.tmp #{authorized_file} && chmod 0700 .ssh && chmod 0600 #{authorized_file}"
    end
  end
end
