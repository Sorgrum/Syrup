require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:unit) {|t| t.pattern = "spec/unit/**/*_spec.rb"}
RSpec::Core::RakeTask.new(:e2e) {|t| t.pattern = "spec/e2e/**/*_spec.rb"}
RSpec::Core::RakeTask.new(:spec)

task default: :spec
