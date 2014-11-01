require 'spec_helper_acceptance'

describe 'accounts' do
  hosts.each do |host|
    context host.name.to_s do
      context 'simple create user' do
        before do
          apply_manifest host, <<-PP
            account::user { 'dude':
              uid      => 2000,
              password => '$6$7EZOrPqchxO$toltzilUL.iCuLnip6J46pkbQkonB1Nm9y0p1Vj5sadKrhAhe7KokZrh.kJyg7ZeXJJELTEZAMdUc8.gw.G4P1',
            }
          PP
        end

        after do
          apply_manifest host, <<-PP
            file { '/home/dude': ensure => 'absent', force => true }
            user { 'dude': ensure => 'absent', require => File['/home/dude'] }
            group { 'dude': ensure => 'absent', require => User['dude'] }
          PP

          user('dude').should_not exist
          file('/home/dude').should_not be_file
          file('/home/dude').should_not be_directory
          file('/home/dude').should_not be_socket
          group('dude').should_not exist
        end

        describe user('dude'), :node => host do
          it { should exist }
          it { should have_uid 2000 }
          it { should have_home_directory '/home/dude' }
          it { should belong_to_group 'dude' }
        end

        describe file('/home/dude'), :node => host do
          it { should be_directory }
          it { should be_mode 750 }
          it { should be_owned_by 'dude' }
        end
      end

      context 'user with ssh-key' do
        before do
          apply_manifest host, <<-PP
            account::user { 'dude':
              uid          => 2000,
              password     => '$6$7EZOrPqchxO$toltzilUL.iCuLnip6J46pkbQkonB1Nm9y0p1Vj5sadKrhAhe7KokZrh.kJyg7ZeXJJELTEZAMdUc8.gw.G4P1',
              email        => 'email@example.com',
              ssh_key      => '#{RSA_PUBLIC_KEY}',
              ssh_key_type => 'ssh-rsa',
            }
          PP
        end

        after do
          apply_manifest host, <<-PP
            file { '/home/dude': ensure => 'absent', force => true }
            user { 'dude': ensure => 'absent', require => File['/home/dude'] }
            group { 'dude': ensure => 'absent', require => User['dude'] }
          PP

          user('dude').should_not exist
          file('/home/dude').should_not be_file
          file('/home/dude').should_not be_directory
          file('/home/dude').should_not be_socket
          group('dude').should_not exist
        end

        describe file('/home/dude/.ssh') do
          it { should be_directory }
          it { should be_mode 700 }
        end

        describe file('/home/dude/.ssh/authorized_keys') do
          it { should be_file }
          it { should be_mode 600 }
          its(:content) { should include "ssh-rsa #{RSA_PUBLIC_KEY} email@example.com" }
        end

        it 'should be able to passwordless ssh with private key' do
          shell "cat > /root/.ssh/id_rsa <<EOF\n#{RSA_PRIVATE_KEY}\nEOF\n"
          shell 'chmod 600 /root/.ssh/id_rsa'
          shell 'ssh dude@localhost "whoami"' do |result|
            result.exit_code.should == 0
            result.output.split("\n").should == ['dude']
          end
          shell 'rm /root/.ssh/id_rsa'
        end
      end
    end
  end
end
