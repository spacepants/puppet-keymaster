require 'spec_helper'

describe 'keymaster::deploy::x509_key', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      context 'with default keymaster and preseeded key' do
        let :pre_condition do
          'include keymaster'
        end
        context 'with no parameters' do
          let :title do
            'test.example.org'
          end
          it { is_expected.to contain_file('x509_test.example.org_private_key').with(
            ensure: 'file',
            path:   '/etc/pki/tls/private/test.example.org.pem',
            owner:  nil,
            group:  nil,
            ).with_content(
              "-----BEGIN RSA PRIVATE KEY-----THISISAFAKERSAHASH-----END RSA PRIVATE KEY-----\n"
            )
          }
        end
        context 'when absent' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              ensure: 'absent'
            }
          end
          it { is_expected.to contain_file('x509_test.example.org_private_key').with_ensure('absent') }
        end
        context 'with using parameters' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              path:  '/some/other/key.foo',
              owner: 'nobody',
              group: 'nobody',
            }
          end
          it { is_expected.to contain_file('x509_test.example.org_private_key').with(
            path:  '/some/other/key.foo',
            owner: 'nobody',
            group: 'nobody',
            )
          }
        end
        context 'when deploying a certificate that does not exist' do
          let :title do
            'nowhere.com'
          end
          it { is_expected.not_to contain_file('x509_nowhere.com_certificate') }
          it { is_expected.to contain_notify('x509_nowhere.com_key_did_not_run').with_message(
            "Can't read key /etc/puppetlabs/keymaster/x509/nowhere.com/key.pem"
            )
          }
        end
      end
    end
  end
end
