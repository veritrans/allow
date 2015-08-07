$:.push(File.expand_path("../lib", __FILE__))
require 'allow/version'

Gem::Specification.new do |s|
  s.name        = "allow"
  s.version     = Allow::VERSION
  s.author      = ["Pavel Evstigneev", "Veritrans team"]
  s.email       = ["pavel.evstigneev@veritrans.co.id"]
  s.homepage    = "http://github.com/veritrans/allow"
  s.summary     = %q{Permission library}
  s.description = "Library to manage users' permissions. Build in object oriented way, have support for rails, activerecord and activeadmin"
  s.licenses    = ['MIT']

  s.files      = `git ls-files`.split("\n")
  s.test_files = []

  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", ">= 2.9.0", "< 3"
  s.add_development_dependency "rspec-rails", '~> 0'
  s.add_development_dependency "rails", '~> 0'
  s.add_development_dependency 'sqlite3', '~> 0'
end
