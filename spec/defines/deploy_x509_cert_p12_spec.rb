require 'spec_helper'

describe 'keymaster::deploy::x509_cert::p12', type: :define do
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
          it { is_expected.to contain_keymaster__deploy__x509_cert('test.example.org').with(
            ensure: 'present',
            )
          }
          it { is_expected.to contain_keymaster__deploy__x509_key('test.example.org').with(
            ensure: 'present',
            )
          }
          it { is_expected.to contain_exec('convert_test.example.org_to_p12').with(
            command: 'openssl pkcs12 -export -out /etc/pki/tls/certs/test.example.org.p12 -in /etc/pki/tls/certs/test.example.org.pem -inkey /etc/pki/tls/private/test.example.org.key',
            path: '/usr/bin:/usr/sbin:/bin:/sbin',
            refreshonly: true,
            ).that_comes_before('File[x509_test.example.org_p12]').that_subscribes_to(
              [
                'File[x509_test.example.org_certificate]',
                'File[x509_test.example.org_private_key]',
              ]
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_p12').with(
            ensure: 'file',
            path: '/etc/pki/tls/certs/test.example.org.p12',
            )
          }
        end
        context 'with custom parameters' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              path: '/path/to/keyfile',
              owner: 'specuser',
              group: 'specgroup',
              pass:  'specpass',
            }
          end
          it { is_expected.to contain_exec('convert_test.example.org_to_p12').with(
            command: 'openssl pkcs12 -export -out /path/to/keyfile -in /etc/pki/tls/certs/test.example.org.pem -inkey /etc/pki/tls/private/test.example.org.key -passout pass:specpass',
            path: '/usr/bin:/usr/sbin:/bin:/sbin',
            refreshonly: true,
            ).that_comes_before('File[x509_test.example.org_p12]').that_subscribes_to(
              [
                'File[x509_test.example.org_certificate]',
                'File[x509_test.example.org_private_key]',
              ]
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_p12').with(
            ensure: 'file',
            path: '/path/to/keyfile',
            )
          }
        end
        context 'when deploying a pfx certificate' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              type: 'pfx'
            }
          end
          it { is_expected.to contain_exec('convert_test.example.org_to_pfx').with(
            command: 'openssl pkcs12 -export -out /etc/pki/tls/certs/test.example.org.pfx -in /etc/pki/tls/certs/test.example.org.pem -inkey /etc/pki/tls/private/test.example.org.key',
            path: '/usr/bin:/usr/sbin:/bin:/sbin',
            refreshonly: true,
            ).that_comes_before('File[x509_test.example.org_pfx]').that_subscribes_to(
              [
                'File[x509_test.example.org_certificate]',
                'File[x509_test.example.org_private_key]',
              ]
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_pfx').with(
            ensure: 'file',
            path: '/etc/pki/tls/certs/test.example.org.pfx',
            )
          }
        end
        context 'when not including the key' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              key: false
            }
          end
          it { is_expected.not_to contain_keymaster__deploy__x509_key('test.example.org') }
          it { is_expected.to contain_exec('convert_test.example.org_to_p12').with(
            command: 'openssl pkcs12 -export -out /etc/pki/tls/certs/test.example.org.p12 -in /etc/pki/tls/certs/test.example.org.pem -nokeys',
            path: '/usr/bin:/usr/sbin:/bin:/sbin',
            refreshonly: true,
            ).that_comes_before('File[x509_test.example.org_p12]').that_subscribes_to(
              'File[x509_test.example.org_certificate]'
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
          it { is_expected.to contain_keymaster__deploy__x509_cert('test.example.org').with(
            ensure: 'absent',
            )
          }
          it { is_expected.to contain_keymaster__deploy__x509_key('test.example.org').with(
            ensure: 'absent',
            )
          }
          it { is_expected.not_to contain_exec('convert_test.example.org_to_p12') }
          it { is_expected.to contain_file('x509_test.example.org_p12').with(
            ensure: 'absent',
            path: '/etc/pki/tls/certs/test.example.org.p12',
            )
          }
        end
      end
      context 'with default keymaster and preseeded certificate and predefined cert and key' do
        let :pre_condition do
          "include keymaster\n::keymaster::deploy::x509_cert { 'test.example.org': }\n::keymaster::deploy::x509_key { 'test.example.org': }"
        end
        context 'when present' do
          let :title do
            'test.example.org'
          end
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_exec('convert_test.example.org_to_p12').with(
            command: 'openssl pkcs12 -export -out /etc/pki/tls/certs/test.example.org.p12 -in /etc/pki/tls/certs/test.example.org.pem -inkey /etc/pki/tls/private/test.example.org.key',
            path: '/usr/bin:/usr/sbin:/bin:/sbin',
            refreshonly: true,
            ).that_comes_before('File[x509_test.example.org_p12]').that_subscribes_to(
              [
                'File[x509_test.example.org_certificate]',
                'File[x509_test.example.org_private_key]',
              ]
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_p12').with(
            ensure: 'file',
            path: '/etc/pki/tls/certs/test.example.org.p12',
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
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_keymaster__deploy__x509_cert('test.example.org').with(
            ensure: 'present',
            )
          }
          it { is_expected.to contain_keymaster__deploy__x509_key('test.example.org').with(
            ensure: 'present',
            )
          }
          it { is_expected.not_to contain_exec('convert_test.example.org_to_p12') }
          it { is_expected.to contain_file('x509_test.example.org_p12').with(
            ensure: 'absent',
            path: '/etc/pki/tls/certs/test.example.org.p12',
            )
          }
        end
      end
    end
  end
end
