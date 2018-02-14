require 'spec_helper'

describe 'keymaster::ssh_key', type: :define do
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
            'tester@test.example.org'
          end
          it { is_expected.to contain_class('keymaster::params') }
          it { is_expected.to contain_file('tester@test.example.org_dir').with(
            'ensure' => 'directory',
            'path'   => '/etc/puppetlabs/keymaster/ssh/tester_at_test.example.org',
            'mode'   => '0750',
            'owner' => 'puppet',
            'group' => 'puppet'
            )
          }
          it { is_expected.to contain_file('tester@test.example.org_key').with(
            'ensure' => 'present',
            'path'   => '/etc/puppetlabs/keymaster/ssh/tester_at_test.example.org/key',
            'mode'   => '0600',
            'owner' => 'puppet',
            'group' => 'puppet'
            )
          }
          it { is_expected.to contain_file('tester@test.example.org_pub').with(
            'ensure' => 'present',
            'path'   => '/etc/puppetlabs/keymaster/ssh/tester_at_test.example.org/key.pub',
            'mode'   => '0600',
            'owner' => 'puppet',
            'group' => 'puppet'
            )
          }
          it { is_expected.to contain_exec('Create key tester@test.example.org: rsa, 4096 bits').with(
            'command' => 'ssh-keygen -t rsa -b 4096 -f /etc/puppetlabs/keymaster/ssh/tester_at_test.example.org/key -C \'rsa 4096\' -N \'\'',
            'user'    => 'puppet',
            'group'   => 'puppet',
            'creates' => '/etc/puppetlabs/keymaster/ssh/tester_at_test.example.org/key',
            'before'  => [
              'File[tester@test.example.org_key]',
              'File[tester@test.example.org_pub]',
            ],
            'require' => 'File[tester@test.example.org_dir]'
            )
          }
          it { is_expected.not_to contain_exec('Revoke previous key tester@test.example.org: force=true') }
        end
        context 'when specifying a DSA key' do
          let :title do
            'tester@test.example.org'
          end
          let :params do
            {
              keytype: 'dsa',
              length:  '4096',
            }
          end
          it { is_expected.to contain_exec('Create key tester@test.example.org: dsa, 1024 bits').with(
            'command' => "ssh-keygen -t dsa -b 1024 -f /etc/puppetlabs/keymaster/ssh/tester_at_test.example.org/key -C 'dsa 1024' -N ''"
            )
          }
        end
        context 'when forcing key replacement' do
          let :title do
            'tester@test.example.org'
          end
          let :params do
            {
              force: true
            }
          end
          it { is_expected.to contain_exec('Revoke previous key tester@test.example.org: force=true').with(
            'command' => 'rm /etc/puppetlabs/keymaster/ssh/tester_at_test.example.org/key /etc/puppetlabs/keymaster/ssh/tester_at_test.example.org/key.pub',
            'before'  => 'Exec[Create key tester@test.example.org: rsa, 4096 bits]'
            )
          }
        end
        # @TODO Tests for maxage and mindate
      end
    end
  end
end
