# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rspec/core/rake_task'

Rake::TestTask.new do |t|
  t.pattern = 'test/*_spec.rb'
end

task default: :test
