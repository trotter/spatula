# Prepare :server: for chef solo to run on it
module Spatula
  class Prepare < SshCommand
    def run
      send "run_for_#{os}"
    end

    def os
      etc_issue = `#{ssh_command("cat /etc/issue")}`
      if etc_issue =~ /ubuntu/i
        "ubuntu"
      else
        raise "Sorry, we currently only support ubuntu for preparing. Please fork http://github.com/trotter/spatula and add support for your OS. I'm happy to incorporate pull requests."
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
  end
end
