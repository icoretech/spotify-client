# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'spotify/version'

Gem::Specification.new do |s|
  s.name          = "spotify-client"
  s.version       = Spotify::VERSION
  s.authors       = ["Claudio Poli"]
  s.email         = ["claudio@icorete.ch"]
  s.homepage      = "https://github.com/icoretech/spotify-client"
  s.summary       = "Ruby client for the Spotify Web API"
  s.description   = "Ruby client for the Spotify Web API"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'

  s.add_dependency 'excon', '~> 0.37'
  s.add_development_dependency 'rspec', '~> 3.0'
  # s.add_development_dependency 'vcr'
  s.add_development_dependency 'guard-rspec'
end
