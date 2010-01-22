# Search for cookbooks matching :query:
module Spatula
  class Search
    Spatula.register("search", self)

    def self.run(*args)
      new(*args).run
    end

    def initialize(query, start=0, count=10)
      @query = query
      @start = start
      @count = count
    end

    def run
      url = URI.parse("%s/search?q=%s&start=%s&items=%s" % [BASE_URL, @query, @start, @count])
      response = Net::HTTP.get(url)
      items = JSON.parse(response)["items"]
      items.each do |item|
        puts [item["cookbook_name"], item["cookbook_description"], item["cookbook_maintainer"]].join("\t")
      end
    end
  end
end

