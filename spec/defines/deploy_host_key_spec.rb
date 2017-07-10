require 'spec_helper'

describe 'keymaster::deploy::host_key', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      context 'with default keymaster and preseeded key' do
        let :pre_condition do
          "include keymaster\ninclude ssh"
        end
        context 'with no parameters' do
          let :title do
            'test.example.org'
          end
          it { is_expected.to contain_class('keymaster::params') }
          it { is_expected.to contain_ssh__server__host_key('test.example.org').with(
            'private_key_content' => "-----BEGIN RSA PRIVATE KEY-----THISISAFAKERSAHASH-----END RSA PRIVATE KEY-----\n",
            'public_key_content'  => "ssh-rsa THISISAFAKERSAHASH test.example.org\n"
            )
          }
        end
        context 'when ensure is absent' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              ensure: 'absent',
            }
          end
          it { is_expected.not_to contain_ssh__server__host_key('test.example.org') }
        end
        context 'when key source files not present' do
          let :title do
            'some.other.org'
          end
          it { is_expected.to contain_notify('host_key_some.other.org_did_not_run').with_message(
            "Can't read public key /etc/puppetlabs/keymaster/host_key/some.other.org/key.pub"
            )
          }
        end
      end
    end
  end
end
