require 'spec_helper'

describe 'keymaster::deploy::ssh_authorized_key', type: :define do
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
            'tester@test.example.org'
          end
          let :params do
            {
              user: 'tester'
            }
          end
          it { is_expected.to contain_class('keymaster::params') }
          it { is_expected.to contain_ssh_authorized_key('tester@test.example.org').with(
            ensure: 'present',
            user:   'tester',
            type:   'ssh-rsa',
            key:    'THISISAFAKERSAHASH',
            )
          }
          it { is_expected.to contain_ssh_authorized_key('tester@test.example.org').without('options') }
        end
        describe 'when setting options' do
          let :title do
            'tester@test.example.org'
          end
          let :params do
            {
              user:    'tester',
              options: '--these --are --options'
            }
          end
          it { is_expected.to contain_ssh_authorized_key('tester@test.example.org').with_options('--these --are --options') }
        end
        describe 'when ensure is absent' do
          let :title do
            'tester@test.example.org'
          end
          let :params do
            {
              user:   'tester',
              ensure: 'absent'
            }
          end
          it { is_expected.to contain_ssh_authorized_key('tester@test.example.org').with_ensure('absent')}
        end
      end
    end
  end
end
