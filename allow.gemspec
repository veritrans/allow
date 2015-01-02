$:.push(File.expand_path("../lib", __FILE__))
require 'allow/version'

Gem::Specification.new do |s|
  s.name       = "veritrans"
  s.version    = Allow::VERSION
  s.author     = ["Pavel Evstigneev", "Turbo team"]
  s.email      = ["pavel.evstigneev@veritrans.co.id"]
  s.homepage   = "http://git.vt-stage.info/paxa/allow"
  s.summary    = %q{Permission library}

  s.files      = `git ls-files`.split("\n")
  s.test_files = []

  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", ">= 2.9.0"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rails"
  #s.add_development_dependency 'activeadmin'
  s.add_development_dependency 'sqlite3'
end
