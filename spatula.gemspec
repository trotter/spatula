PKG_VERSION = "0.0.7"
PKG_FILES   = Dir['README.textile',
                  'bin/*',
                  'lib/**/*.rb']

$spec = Gem::Specification.new do |s|
  s.name = 'spatula'
  s.version = PKG_VERSION
  s.summary = "Command line helper app for use with Chef"
  s.description = <<EOS
  Spatula is a command line helper app for use with Chef. It currently lets you
  search and install cookbooks from http://cookbooks.opscode.com.
EOS
  
  s.add_dependency("thor", ">= 0.13.4")
  s.add_dependency("json", ">= 1.2.4")
  s.files       = PKG_FILES.to_a
  s.bindir      = 'bin'
  s.executables = 'spatula'
  s.has_rdoc    = false
  s.author      = "Trotter Cashion"
  s.email       = "cashion@gmail.com"
  s.homepage    = "http://trottercashion.com"
end
