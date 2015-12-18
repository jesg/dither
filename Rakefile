require 'bundler'

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

if RUBY_PLATFORM =~ /java/
  require 'rake/javaextensiontask'
  Rake::JavaExtensionTask.new('dither')
else
  require 'rake/extensiontask'
  Rake::ExtensionTask.new('dither')
end

task :default => :spec

