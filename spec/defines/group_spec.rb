require 'spec_helper'

describe 'account::group' do
  let(:title) { 'dudes' }

  it { should compile }

  it { should contain_group('dudes') }
  it { should contain_group('dudes').with_ensure 'present' }

  context 'with groupname param' do
    let(:params) { {:groupname => 'dudesses'} }

    it { should contain_group('dudesses') }
    it { should contain_group('dudesses').with_ensure 'present' }
  end

  context 'with gid param' do
    let(:params) { {:gid => 1000} }

    it { should contain_group('dudes') }
    it { should contain_group('dudes').with_gid 1000 }
  end
end
