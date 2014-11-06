require 'beaker-rspec'
require 'pry'

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    install_package host, 'rubygems'
    on host, 'gem install puppet --no-ri --no-rdoc'
    on host, "mkdir -p #{host['distmoduledir']}"
  end
end

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation
  c.before :suite do
    # puppet_module_install(:source => proj_root, :module_name => 'module name') XXX
  end
end

def apply_manifest(host, manifest)
  # Run it twice and test for idempotency
  apply_manifest_on(host, manifest, :catch_failures => true)
  apply_manifest_on(host, manifest, :catch_failures => true).exit_code.should be_zero
end
