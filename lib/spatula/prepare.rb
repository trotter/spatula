# Prepare :server: for chef solo to run on it
module Spatula
  class Prepare < SshCommand
    def run
      send "run_for_#{os}"
    end

    def os
      etc_issue = `#{ssh_command("cat /etc/issue")}`
      case etc_issue
      when /ubuntu/i
        "ubuntu"
      when /debian/i
        "debian"
      else
        raise "Sorry, we currently only support ubuntu & debian for preparing. Please fork http://github.com/trotter/spatula and add support for your OS. I'm happy to incorporate pull requests."
      end
    end

    def run_for_ubuntu
      ssh "sudo apt-get update"
      ssh "sudo aptitude -y install ruby irb ri libopenssl-ruby1.8 libshadow-ruby1.8 ruby1.8-dev gcc g++ rsync curl"
      ssh "curl -L 'http://rubyforge.org/frs/download.php/69365/rubygems-1.3.6.tgz' | tar xvzf -"
      ssh "cd rubygems* && sudo ruby setup.rb --no-ri --no-rdoc"
      ssh "sudo ln -sfv /usr/bin/gem1.8 /usr/bin/gem"

      ssh "sudo gem install rdoc chef ohai --no-ri --no-rdoc --source http://gems.opscode.com --source http://gems.rubyforge.org"
    end

    def run_for_debian
      ssh 'sudo apt-get update'
      ssh 'sudo apt-get install -y build-essential zlib1g-dev libssl-dev libreadline5-dev curl rsync screen vim'
      ssh 'curl -L http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz | tar xzvf -'
      # install REE 1.8.7 (and rubygems and irb and rake) to /usr
      ssh 'cd ruby-enterprise-1.8.7-2010.02 && sudo echo -e "\n/usr\n" | ./installer'

      ssh "sudo gem install rdoc chef ohai --no-ri --no-rdoc --source http://gems.opscode.com --source http://gems.rubyforge.org"
    end
  end
end
