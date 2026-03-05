# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

if ENV['EXCON'] == 'head'
  gem 'excon', git: 'https://github.com/excon/excon.git'
elsif ENV['EXCON']
  gem 'excon', ENV['EXCON']
end

# Keep tooling explicit for local and CI runs.
gem 'rake', '>= 13.1'
gem 'rspec', '>= 3.13'
gem 'simplecov', '>= 0.22'
gem 'rubocop', '>= 1.70'
gem 'rubocop-rspec', '>= 3.0'
