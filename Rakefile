require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test

task :console do
  exec "EXCON_DEBUG=true irb -r spotify-client -I ./lib"
  # exec "irb -r spotify-client -I ./lib"
end
