#!/usr/bin/env ruby

require 'rubygems'
require 'virtualbox'

module VirtualBox
  class VM
    def main_interface_name
      interface = nics.first.nictype
      case interface
      when /82540EM/
        return 'e1000'
      else
        abort "Cannot reliably determine the network interface. Email trotter (cashion@gmail.com)"
      end
    end

    def set_interface_data service, key, value
      extra_data["VBoxInternal/Devices/#{main_interface_name}/0/LUN#0/Config/#{service}/#{key}"] = value
    end

    def forward_port service, from, to, protocol="TCP"
      set_interface_data service, "HostPort",  from
      set_interface_data service, "GuestPort", to
      set_interface_data service, "Protocol",  protocol
    end
  end
end

if __FILE__ == $0
  port  = File.read(File.dirname(__FILE__) + "/ssh_port").chomp.to_i
  image = ARGV[0] || abort("Usage: #$0 <image-name>")

  vm = VirtualBox::VM.find(image)

  puts "Forwarding ports for ssh"
  vm.forward_port 'SSH', port, 22 
  vm.save
end
