require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.name = "test:integration"
  t.pattern = 'test/integration/*_test.rb'
end