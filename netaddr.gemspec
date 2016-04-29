# build install with:  gem build netaddr.gemspec
# install with: netaddr*.gem
Gem::Specification.new do |s|
    s.name      =   "netaddr"
    s.version   =   "1.6.1"
    s.date      =   "2016-03-25"
    s.author    =   "Dustin Spinhirne"
    s.summary   =   "A package for manipulating network addresses."
    s.files = Dir['lib/*.rb'] + Dir['test/*']
    s.require_paths = ['lib']
    s.extra_rdoc_files  =   ["README.md", "Errors", "changelog", "license"]
    s.license  =   'Apache-2.0'
end 

