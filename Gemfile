# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

if ENV['EXCON'] == 'head'
  gem 'excon', git: 'https://github.com/excon/excon.git'
elsif ENV['EXCON']
  gem 'excon', ENV['EXCON']
end

# Keep tooling explicit for local and CI runs.
gem 'rake', '>= 13.4.2'
gem 'rspec', '>= 3.13.2'
gem 'rubocop', '>= 1.92.2'
gem 'rubocop-rspec', '>= 3.10.2'
gem 'simplecov', '>= 1.3.2'
