# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:lint) do |task|
  task.patterns = ['lib/**/*.rb', '*.gemspec', 'Rakefile']
end

task default: %i[lint spec]

task :console do
  exec 'EXCON_DEBUG=true irb -r spotify-client -I ./lib'
end
