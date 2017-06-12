require 'spec_helper'

describe 'keymaster::deploy::ssh_known_host', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      context 'with default keymaster and preseeded key' do
        let :pre_condition do
          "include keymaster\nuser{'tester': home => '/home/tester', gid => 'tester'}"
        end
        describe 'with minimum parameters' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              user: 'tester'
            }
          end
          it { is_expected.to contain_class('keymaster::params') }
          it { is_expected.to contain_sshkey('tester_test.example.org').with(
            name:         'test.example.org',
            ensure:       'present',
            host_aliases: [],
            key:          'THISISAFAKERSAHASH',
            target:       '/home/tester/.ssh/known_hosts',
            type:         'ssh-rsa',
            )
          }
          it { is_expected.to contain_file('/home/tester/.ssh').with(
            ensure: 'directory',
            owner:  'tester',
            group:  'tester',
            mode:   '0700',
            )
          }
        end
        describe 'with all parameters' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              user:    'tester',
              path:    '/path/to/known_hosts',
              aliases: [
                'test',
                '1.2.3.4',
              ]
            }
          end
          it { is_expected.not_to contain_file('/home/tester/.ssh') }
          it { is_expected.to contain_sshkey('tester_test.example.org').with(
            name:         'test.example.org',
            ensure:       'present',
            host_aliases: [
              'test',
              '1.2.3.4',
            ],
            key:          'THISISAFAKERSAHASH',
            target:       '/path/to/known_hosts',
            type:         'ssh-rsa',
            )
          }
        end
        describe 'when ensure is absent' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              user:   'tester',
              ensure: 'absent'
            }
          end
          it { is_expected.not_to contain_file('/home/tester/.ssh') }
          it { is_expected.to contain_sshkey('tester_test.example.org').with_ensure('absent') }
        end
      end
    end
  end
end
