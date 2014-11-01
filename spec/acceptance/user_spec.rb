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
    end
  end
end
