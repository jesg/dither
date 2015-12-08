require 'bundler'

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rake/extensiontask'
Rake::ExtensionTask.new('dither')

task :default => :spec
