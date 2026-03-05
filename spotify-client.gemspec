# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
version_file = File.expand_path('lib/spotify/version.rb', __dir__)
version = File.read(version_file).match(/VERSION = '([^']+)'/)&.captures&.first
raise 'Could not determine gem version' unless version

Gem::Specification.new do |spec|
  spec.name = 'spotify-client'
  spec.version = version
  spec.authors = ['Claudio Poli']
  spec.email = ['masterkain@gmail.com']

  spec.summary = 'Ruby client for the Spotify Web API'
  spec.description = 'Lightweight Ruby client for the Spotify Web API with playlist and catalog helpers.'
  spec.homepage = 'https://github.com/icoretech/spotify-client'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata['source_code_uri'] = 'https://github.com/icoretech/spotify-client'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/icoretech/spotify-client/issues'
  spec.metadata['changelog_uri'] = 'https://github.com/icoretech/spotify-client/releases'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir[
    'lib/**/*.rb',
    'README*',
    'LICENSE*',
    '*.gemspec'
  ]
  spec.require_paths = ['lib']

  spec.add_dependency 'excon', '>= 0.112', '< 2.0'
  spec.add_dependency 'logger', '>= 1.7'
end
