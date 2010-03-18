require 'test/unit'

SPATULA_ROOT = File.dirname(__FILE__) + '/../..'
VM_PORT = 3322
IDENTITY = SPATULA_ROOT + '/test/keys/spatula-integration'

class SpatulaTest < Test::Unit::TestCase
  def setup
    start_vm("spatula-ubuntu-9.10-64bit")
  end

  def teardown
    stop_vm
  end

  def test_prepares_server
    sh "ruby #{SPATULA_ROOT}/lib/spatula.rb prepare localhost --port=#{VM_PORT} --login=spatula --identity=#{IDENTITY}"
    assert ssh("gem list | grep chef")
  end

  def start_vm(vm)
    sh "VBoxManage startvm #{vm}"
    sleep 2 until ssh "ls"
  end

  def stop_vm
    unless ssh "sudo shutdown -h now"
      raise "Cannot connect to VM, are you sure it is running?"
    end
  end

  def ssh(command)
    sh %Q|ssh -l spatula -p #{VM_PORT} -i #{IDENTITY} localhost "#{command.gsub('"', '\\"')}"|
  end

  def sh(command)
    puts "running: #{command}"
    system command
  end
end
