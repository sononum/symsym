# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "symsym"
  gem.homepage = "http://github.com/sononum/symsym"
  gem.license = "MIT"
  gem.summary = %Q{Crashlog symbolizer for Mac OS X}
  gem.description = %Q{symsym can be used to symbolize crashlogs from dSYM files}
  gem.email = "ulizurucker@googlemail.com"
  gem.authors = ["Ulrich Zurucker"]
  gem.executables = ["symsym"]
  gem.default_executable = 'symsym'
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new


require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "symsym #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
