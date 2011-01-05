# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'restfulx/version'

Gem::Specification.new do |s|
  s.name        = "restfulx"
  s.version     = RestfulX::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dima Berastau"]
  s.email       = ["dima.berastau@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/restfulx"
  s.summary     = "RestfulX Framework Code Generation Engine / Rails 3.x Integration Support"
  s.description = "RestfulX: The RESTful Way to develop Adobe Flex and AIR applications"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "restfulx"

  s.add_dependency("activesupport", ["~> 3.0"])
  s.add_development_dependency "bundler", ">= 1.0.0.rc.4"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{|f| f =~ /^bin/}.map{|f| f.sub(/^bin\//, '')}
  s.require_path = 'lib'
end