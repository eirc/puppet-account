source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 3.3']
  gem 'puppet', puppetversion
  gem 'facter', '>= 1.7.0'
  gem 'puppetlabs_spec_helper'
  gem 'guard-rake'

  # Basic syntax tests
  gem 'puppet-syntax'
  gem 'puppet-lint'

  # Unit testing
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'

  # Acceptance testing
  gem 'beaker'
  gem 'beaker-rspec', :require => false
  gem 'pry'
  gem 'fission'
end
