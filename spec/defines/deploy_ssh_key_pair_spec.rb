require 'spec_helper'

describe 'keymaster::deploy::ssh_key_pair', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      context 'with default keymaster and preseeded keypair' do
        let :pre_condition do
          "include keymaster\nuser{'tester': home => '/home/tester', gid => 'tester'}"
        end
        context 'with required parameters' do
          let :title do
            'tester@test.example.org'
          end
          let :params do
            {
              user:     'tester',
              filename: 'id_rsa'
            }
          end
          it { is_expected.to contain_class('keymaster::params') }
          it { is_expected.to contain_file('/home/tester/.ssh').with(
            ensure: 'directory',
            owner:  'tester',
            group:  'tester',
            mode:   '0700',
            )
          }
          it { is_expected.to contain_file('/home/tester/.ssh/id_rsa').with(
            ensure: 'file',
            owner:  'tester',
            group:  'tester',
            mode:   '0600',
            'content' => "-----BEGIN RSA PRIVATE KEY-----THISISAFAKERSAHASH-----END RSA PRIVATE KEY-----\n",
            ).that_requires('File[/home/tester/.ssh]')
          }
          it { is_expected.to contain_file('/home/tester/.ssh/id_rsa.pub').with(
            'ensure'  => 'file',
            'owner'   => 'tester',
            'group'   => 'tester',
            'mode'    => '0644',
            'content' => "ssh-rsa THISISAFAKERSAHASH tester@test.example.org\n",
            'require' => 'File[/home/tester/.ssh]'
            )
          }
        end
        context 'when ensure is absent' do
          let :title do
            'tester@test.example.org'
          end
          let :params do
            {
              ensure:   'absent',
              user:     'tester',
              filename: 'id_rsa'
            }
          end
          it { is_expected.to contain_file('/home/tester/.ssh/id_rsa').with_ensure('absent') }
          it { is_expected.to contain_file('/home/tester/.ssh/id_rsa.pub').with_ensure('absent') }
        end
        context 'when key source files not present' do
          let :title do
            'notfound@some.other.org'
          end
          let :params do
            {
              user:     'tester',
              filename: 'id_rsa'
            }
          end
          it { is_expected.to contain_notify('ssh_keypair_notfound@some.other.org_did_not_run').with(
            'message' => 'Can\'t read public key /etc/puppetlabs/keymaster/ssh/notfound_at_some.other.org/key.pub'
            )
          }
        end
      end
    end
  end
end
