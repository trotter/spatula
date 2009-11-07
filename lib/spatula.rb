require 'rubygems'
require 'net/http'
require 'uri'
require 'json'

class Spatula
  BASE_URL = "http://cookbooks.opscode.com/api/v1"

  # Search for cookbooks matching :query:
  def search(query, start=0, items=10)
    url = URI.parse("%s/search?q=%s&start=%s&items=%s" % [BASE_URL, query, start, items])
    response = Net::HTTP.get(url)
    items = JSON.parse(response)["items"]
    items.each do |item|
      puts [item["cookbook_name"], item["cookbook_description"], item["cookbook_maintainer"]].join("\t")
    end
  end

  # Show the cookbook named :name:
  def show(name)
    print_response(get_cookbook_info(name))
  end

  # Show the latest version of the cookbook named :name:
  def show_latest_version(name)
    print_response(get_version_info(name))
  end

  # Install the cookbook :name: into cwd/cookbooks
  #   Will create a cookbook_tarballs dir for storing downloaded tarballs
  def install(name)
    file = JSON.parse(get_version_info(name))["file"]
    filename = File.basename(file)
    FileUtils.mkdir_p("cookbook_tarballs")
    `curl #{file} -o cookbook_tarballs/#{filename}`
    `tar xzvf cookbook_tarballs/#{filename} -C cookbooks`
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

if __FILE__ == $0
  command = ARGV.shift
  Spatula.new.send(command, *ARGV)
end
