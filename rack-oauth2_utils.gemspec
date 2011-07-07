# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack-oauth2_utils/version"

Gem::Specification.new do |s|
  s.name        = "rack-oauth2_utils"
  s.version     = Rack::OAuth2Utils::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ismael Celis"]
  s.email       = ["ismaelct@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Middleware for catching OAuth2 access tokens in Rack apps}
  s.description = %q{Simple Rack middleware that catches OAuth2 access tokens and validates identity}

  s.rubyforge_project = "rack-oauth2_utils"
  
  s.add_dependency 'rack', ">= 1.2.2"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "minitest"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
