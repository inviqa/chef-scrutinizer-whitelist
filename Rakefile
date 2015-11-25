#!/usr/bin/env rake

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:chefspec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'foodcritic'
FoodCritic::Rake::LintTask.new

require 'stove/rake_task'
Stove::RakeTask.new

task default: %w(rubocop foodcritic chefspec)
task all: %w(default kitchen:all)
