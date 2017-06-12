require 'spec_helper'

describe 'keymaster::deploy::x509_cert', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      context 'with default keymaster and preseeded certificate' do
        let :pre_condition do
          'include keymaster'
        end
        context 'with no parameters' do
          let :title do
            'test.example.org'
          end
          it { is_expected.to contain_file('x509_test.example.org_certificate').with(
            'ensure'  => 'file',
            'path'    => '/etc/pki/tls/certs/test.example.org.pem',
            'owner'   => nil,
            'group'   => nil,
            'content' => "-----BEGIN CERTIFICATE-----THISISAFAKEPEM-----END CERTIFICATE-----\n",
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
          it { is_expected.to contain_file('x509_test.example.org_certificate').with(
            'ensure' => 'absent'
            )
          }
        end
        context 'with using parameters' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              path:  '/some/other/certificate.foo',
              owner: 'nobody',
              group: 'nobody'
            }
          end
          it { is_expected.to contain_file('x509_test.example.org_pem_certificate').with(
            path:  '/some/other/certificate.foo',
            owner: 'nobody',
            group: 'nobody'
            )
          }
        end
        context 'when deploying a certificate that does not exist' do
          let :title do
            'nowhere.com'
          end
          it { is_expected.not_to contain_file('x509_nowhere.com_pem_certificate') }
          it { is_expected.to contain_notify('x509_nowhere.com_cert_did_not_run').with_message("Can't read certificate /etc/puppetlabs/keymaster/x509/nowhere.com/certificate.pem")}
        end
        context 'when deploying a DER crt certificate' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              type: 'crt'
            }
          end
          it { is_expected.to contain_keymaster__deploy__x509_cert__der('test.example.org').with_type('crt') }
        end
        context 'when deploying a DER cer certificate' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              type: 'cer'
            }
          end
          it { is_expected.to contain_keymaster__deploy__x509_cert__der('test.example.org').with_type('cer') }
        end
        context 'when deploying a DER der certificate' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              type: 'der'
            }
          end
          it { is_expected.to contain_keymaster__deploy__x509_cert__der('test.example.org').with_type('der') }
        end
        context 'when deploying a pkcs12 p12 certificate' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              type: 'p12'
            }
          end
          it { is_expected.to contain_keymaster__deploy__x509_cert__p12('test.example.org').with_type('p12') }
        end
        context 'when deploying a pkcs12 pfx certificate' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              type: 'pfx'
            }
          end
          it { is_expected.to contain_keymaster__deploy__x509_cert__p12('test.example.org').with_type('pfx') }
        end
        context 'when setting an invalid type' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              type: 'foo'
            }
          end
          it { is_expected.to raise_error(Puppet::PreformattedError, /Evaluation Error/) }
        end
      end
    end
  end
end
