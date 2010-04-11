#
# Chef Solo Config File
#

base_path = File.expand_path(File.dirname(__FILE__) + '/..')

log_level          :info
log_location       STDOUT
file_cache_path    "/var/chef/cookbooks"

file_cache_path    base_path
cookbook_path      ["#{base_path}/site-cookbooks", 
                    "#{base_path}/cookbooks"]

# Optionally store your JSON data file and a tarball of cookbooks remotely.
#json_attribs "http://chef.example.com/dna.json"
#recipe_url   "http://chef.example.com/cookbooks.tar.gz"

Mixlib::Log::Formatter.show_time = true
