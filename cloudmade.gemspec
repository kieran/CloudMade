#!/usr/bin/env ruby

###
### RubyGems Specification file for CloudMade
###
### $Rev: 1 $
### $Release: 0.0.1 $
### Kieran Huggins kieran-at-refactory-dot-ca.
###

require 'rubygems'

spec = Gem::Specification.new do |s|
  ## package information
  s.name        = 'cloudmade'
  s.author      = 'Kieran Huggins'
  s.version     = ("$Release: 0.0.1 $" =~ /[\.\d]+/) && $&
  s.platform    = Gem::Platform::RUBY
  s.homepage    = 'http://github.com/kieran/cloudmade'
  s.summary = s.description = "'CloudMade' is a library that generates & optionally caches CloudMade static maps with polylines & markers."

  ## files
  files = %w[README.markdown cloudmade.rb cloudmade.gemspec]
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end