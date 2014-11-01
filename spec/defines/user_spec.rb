require 'spec_helper'

describe 'account::user' do
  let(:title) { 'dude' }
  let(:params) { {:uid => 1000, :password => 'password'} }

  it { should compile }

  it { should contain_user('dude') }
  it { should contain_user('dude').with_ensure 'present' }
  it { should contain_user('dude').with_password 'password' }
  it { should contain_user('dude').with_uid 1000 }
  it { should contain_user('dude').with_gid 'dude' }
  it { should contain_user('dude').with_groups [] }
  it { should contain_user('dude').with_shell '/bin/bash' }
  it { should contain_user('dude').with_home '/home/dude' }
  it { should contain_user('dude').with_managehome false }
  it { should contain_user('dude').with_comment ' <>' }
  it { should contain_user('dude').with_expiry 'absent' }
  it { should contain_user('dude').that_requires 'Group[dude]' }

  it { should contain_file('/home/dude') }
  it { should contain_file('/home/dude').with_ensure 'directory' }
  it { should contain_file('/home/dude').with_owner 'dude' }
  it { should contain_file('/home/dude').with_group 'dude' }
  it { should contain_file('/home/dude').with_mode '0750' }
  it { should contain_file('/home/dude').that_requires 'User[dude]' }
  it { should contain_file('/home/dude').that_requires 'Group[dude]' }

  it { should contain_file('/home/dude/.ssh') }
  it { should contain_file('/home/dude/.ssh').with_ensure 'directory' }
  it { should contain_file('/home/dude/.ssh').with_owner 'dude' }
  it { should contain_file('/home/dude/.ssh').with_group 'dude' }
  it { should contain_file('/home/dude/.ssh').with_mode '0700' }
  it { should contain_file('/home/dude/.ssh').that_requires 'File[/home/dude]' }

  it { should contain_file('/home/dude/.ssh/authorized_keys') }
  it { should contain_file('/home/dude/.ssh/authorized_keys').with_ensure 'file' }
  it { should contain_file('/home/dude/.ssh/authorized_keys').with_owner 'dude' }
  it { should contain_file('/home/dude/.ssh/authorized_keys').with_group 'dude' }
  it { should contain_file('/home/dude/.ssh/authorized_keys').with_mode '0600' }
  it { should contain_file('/home/dude/.ssh/authorized_keys').that_requires 'File[/home/dude/.ssh]' }

  it { should_not contain_ssh_authorized_key('dude') }

  context 'without uid param' do
    let(:params) { {:password => 'password'} }

    it { expect { should compile }.to raise_error(/Must pass uid to Account::User\[dude\]/) }
  end

  context 'without password param' do
    let(:params) { {:uid => 1000} }

    it { expect { should compile }.to raise_error(/Must pass password to Account::User\[dude\]/) }
  end

  context 'with username param overriding title as username' do
    let(:params) { {:uid => 1000, :password => 'password', :username => 'username'} }

    it { should contain_user('username') }
    it { should contain_user('username').with_gid 'username' }
    it { should contain_user('username').with_home '/home/username' }
    it { should contain_user('username').that_requires 'Group[username]' }

    it { should contain_file('/home/username') }
    it { should contain_file('/home/username').with_owner 'username' }
    it { should contain_file('/home/username').with_group 'username' }
    it { should contain_file('/home/username').that_requires 'User[username]' }
    it { should contain_file('/home/username').that_requires 'Group[username]' }

    it { should contain_file('/home/username/.ssh') }
    it { should contain_file('/home/username/.ssh').with_owner 'username' }
    it { should contain_file('/home/username/.ssh').with_group 'username' }
    it { should contain_file('/home/username/.ssh').that_requires 'File[/home/username]' }

    it { should contain_file('/home/username/.ssh/authorized_keys') }
    it { should contain_file('/home/username/.ssh/authorized_keys').with_owner 'username' }
    it { should contain_file('/home/username/.ssh/authorized_keys').with_group 'username' }
    it { should contain_file('/home/username/.ssh/authorized_keys').that_requires 'File[/home/username/.ssh]' }
  end

  context 'with full_name param' do
    let(:params) { {:uid => 1000, :password => 'password', :full_name => 'John Doe'} }

    it { should contain_user('dude').with_comment 'John Doe <>' }
  end

  context 'with email param' do
    let(:params) { {:uid => 1000, :password => 'password', :email => 'email@example.com'} }

    it { should contain_user('dude').with_comment ' <email@example.com>' }
  end

  context 'with expiry param' do
    let(:params) { {:uid => 1000, :password => 'password', :expiry => '2050-01-01'} }

    it { should contain_user('dude').with_expiry '2050-01-01' }
  end

  context 'with shell param' do
    let(:params) { {:uid => 1000, :password => 'password', :shell => '/bin/sh'} }

    it { should contain_user('dude').with_shell '/bin/sh' }
  end

  context 'with groups param' do
    let(:params) { {:uid => 1000, :password => 'password', :groups => ['sudo', 'admin']} }
    let(:pre_condition) do
      <<-PP
        account::group { 'admin': gid => 2000 }
        account::group { 'sudo': gid => 2001 }
      PP
    end

    it { should contain_user('dude').with_groups ['sudo', 'admin'] }
  end

  context 'with ssh_key param' do
    let(:params) { {:uid => 1000, :password => 'password', :email => 'email@example.com', :ssh_key => 'ssh-key', :ssh_key_type => 'rsa'} }

    it { should contain_ssh_authorized_key('dude-email@example.com-key') }
    it { should contain_ssh_authorized_key('dude-email@example.com-key').with_ensure 'present' }
    it { should contain_ssh_authorized_key('dude-email@example.com-key').with_key 'ssh-key' }
    it { should contain_ssh_authorized_key('dude-email@example.com-key').with_type 'rsa' }
    it { should contain_ssh_authorized_key('dude-email@example.com-key').with_user 'dude' }
    it { should contain_ssh_authorized_key('dude-email@example.com-key').that_requires 'File[/home/dude/.ssh/authorized_keys]' }

    context 'without email param' do
      let(:params) { {:uid => 1000, :password => 'password', :ssh_key => 'ssh-key', :ssh_key_type => 'rsa'} }
      it { expect { should compile }.to raise_error(/You must provide an email if you provide an ssh key!/) }
    end

    context 'without ssh_key_type param' do
      let(:params) { {:uid => 1000, :password => 'password', :ssh_key => 'ssh-key', :email => 'email@example.com'} }
      it { expect { should compile }.to raise_error(/You must provide an ssh key type if you provide an ssh key!/) }
    end
  end
end
