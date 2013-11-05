require 'spec_helper_system'

describe 'file replacement' do
  context 'file should not replace' do
    before(:all) do
      shell('echo "file exists" >> /tmp/file')
    end
    after(:all) do
      shell('rm -rf /tmp/concat /var/lib/puppet/concat')
    end


    pp="
      concat { '/tmp/file':
        owner   => root,
        group   => root,
        mode    => '0644',
        replace => false,
      }

      concat::fragment { '1':
        target  => '/tmp/file',
        content => '1',
        order   => '01',
      }

      concat::fragment { '2':
        target  => '/tmp/file',
        content => '2',
        order   => '02',
      }
    "

    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end

    describe file('/tmp/file') do
      it { should be_file }
      it { should contain 'file exists' }
      it { should_not contain '1' }
      it { should_not contain '2' }
    end
  end

  context 'symlink' do
    before(:all) do
      shell('mkdir /tmp/concat')
      shell('ln -s /tmp/concat/dangling /tmp/concat/file')
    end
    after(:all) do
      shell('rm -rf /tmp/concat /var/lib/puppet/concat')
    end

    pp="
      concat { '/tmp/concat/file': }

      concat::fragment { '1':
        target  => '/tmp/concat/file',
        content => '1',
      }
    "

    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end

    describe file('/tmp/concat/file') do
      it { should be_file }
      it { should contain '1' }
    end
  end

  context 'directory' do
    before(:all) do
      shell('mkdir /tmp/concat')
      shell('mkdir /tmp/concat/file')
    end
    after(:all) do
      shell('rm -rf /tmp/concat /var/lib/puppet/concat')
    end

    pp="
      concat { '/tmp/concat/file': }

      concat::fragment { '1':
        target  => '/tmp/concat/file',
        content => '1',
      }
    "

    context puppet_apply(pp) do
      its(:stderr) { should =~ /change from directory to file failed/ }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { should =~ /change from directory to file failed/ }
      its(:exit_code) { should_not == 1 }
    end

    describe file('/tmp/concat/file') do
      it { should be_directory }
    end
  end

  context 'directory' do
    before(:all) do
      shell('mkdir /tmp/concat')
      shell('mkdir /tmp/concat/file')
    end
    after(:all) do
      shell('rm -rf /tmp/concat /var/lib/puppet/concat')
    end

    pp="
      concat { '/tmp/concat/file': }

      concat::fragment { '1':
        target  => '/tmp/concat/file',
        content => '1',
      }
    "

    context puppet_apply(pp) do
      its(:stderr) { pending; should be_empty }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { pending; should be_empty }
      its(:exit_code) { pending; should be_zero }
    end

    describe file('/tmp/concat/file') do
      xit { should be_file }
      xit { should contain '1' }
    end
  end
end
