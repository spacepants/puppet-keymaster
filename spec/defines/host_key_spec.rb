require 'spec_helper'

describe 'keymaster::host_key', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with default keymaster' do
        let :pre_condition do
          'include keymaster'
        end
        context 'with no parameters' do
          let :title do
            'test.example.org'
          end
          it { is_expected.to contain_class('keymaster::params') }
          it { is_expected.to contain_file('host_key_test.example.org_dir').with(
            'ensure' => 'directory',
            'path'   => '/etc/puppetlabs/keymaster/host_key/test.example.org',
            'mode'   => '0644',
            'owner' => 'puppet',
            'group' => 'puppet'
            )
          }
          it { is_expected.to contain_file('host_key_test.example.org_key').with(
            'ensure' => 'present',
            'path'   => '/etc/puppetlabs/keymaster/host_key/test.example.org/key',
            'mode'   => '0600',
            'owner' => 'puppet',
            'group' => 'puppet'
            )
          }
          it { is_expected.to contain_file('host_key_test.example.org_pub').with(
            'ensure' => 'present',
            'path'   => '/etc/puppetlabs/keymaster/host_key/test.example.org/key.pub',
            'mode'   => '0600',
            'owner' => 'puppet',
            'group' => 'puppet'
            )
          }
          it { is_expected.to contain_exec('Create key test.example.org: rsa, 2048 bits').with(
            'command' => 'ssh-keygen -t rsa -b 2048 -f /etc/puppetlabs/keymaster/host_key/test.example.org/key -C \'rsa 2048\' -N \'\'',
            'user'    => 'puppet',
            'group'   => 'puppet',
            'creates' => '/etc/puppetlabs/keymaster/host_key/test.example.org/key',
            'before'  => [
              'File[host_key_test.example.org_key]',
              'File[host_key_test.example.org_pub]',
            ],
            'require' => 'File[host_key_test.example.org_dir]'
            )
          }
          it { is_expected.not_to contain_exec('Revoke previous key test.example.org: force=true') }
        end
        context 'when specifying a DSA key' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              keytype: 'dsa',
              length:  '4096'
            }
          end
          it { is_expected.to contain_exec('Create key test.example.org: dsa, 1024 bits').with(
            'command' => "ssh-keygen -t dsa -b 1024 -f /etc/puppetlabs/keymaster/host_key/test.example.org/key -C 'dsa 1024' -N ''"
            )
          }
        end
        context 'when forcing key replacement' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              force: true
            }
          end
          it { is_expected.to contain_exec('Revoke previous key test.example.org: force=true').with(
            'command' => 'rm /etc/puppetlabs/keymaster/host_key/test.example.org/key /etc/puppetlabs/keymaster/host_key/test.example.org/key.pub',
            'before'  => 'Exec[Create key test.example.org: rsa, 2048 bits]'
            )
          }
        end
        # @TODO Tests for maxage and mindate
      end
    end
  end
end
