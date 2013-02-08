#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/testtask"


namespace :test do
  "Runs the unit tests"
  Rake::TestTask.new :unit do |t|
    t.pattern = 'test/unit/**/test_*.rb'
  end

end

desc "Runs all tests"
task :test do
  Rake::Task['test:unit'].invoke
end
