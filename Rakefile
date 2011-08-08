require 'bundler'
Bundler::GemHelper.install_tasks

task :default do
  Rake::Task['run_tests'].invoke
end

task :run_tests do
  if RUBY_VERSION =~ /^1.9/
    require_relative 'test/yourdsl_test'
  else
    require 'test/yourdsl_test'
  end
end
