require 'spec_helper'

describe 'concat::fragment', :type => :defne do
  let(:title) { 'motd_header' }

  let(:facts) do
    {
     :concat_basedir => '/var/lib/puppet/concat',
     :id             => 'root',
    }
  end

  let :pre_condition do
    "concat{ '/etc/motd': }"
  end

  context 'target => /etc/motd' do
    let(:params) {{ :target => '/etc/motd' }}
    it do
      should contain_class('concat::setup')
      should contain_concat('/etc/motd')
      should contain_concat__fragment('motd_header').with({
        :target => '/etc/motd',
      })
    end
  end
end
