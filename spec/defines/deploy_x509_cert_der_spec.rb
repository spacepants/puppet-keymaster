require 'spec_helper'

describe 'keymaster::deploy::x509_cert::der', type: :define do
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
          it { is_expected.to contain_exec('convert_test.example.org_to_crt').with(
            command: 'openssl x509 -outform der -in /etc/pki/tls/certs/test.example.org.pem -out /etc/pki/tls/certs/test.example.org.crt',
            path: '/usr/bin:/usr/sbin:/bin:/sbin',
            refreshonly: true,
            ).that_comes_before('File[x509_test.example.org_crt]').that_subscribes_to(
              'File[x509_test.example.org_certificate]'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_crt').with(
            ensure: 'file',
            path: '/etc/pki/tls/certs/test.example.org.crt',
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
            }
          end
          it { is_expected.to contain_exec('convert_test.example.org_to_crt').with(
            command: 'openssl x509 -outform der -in /etc/pki/tls/certs/test.example.org.pem -out /path/to/keyfile',
            path: '/usr/bin:/usr/sbin:/bin:/sbin',
            refreshonly: true,
            ).that_comes_before('File[x509_test.example.org_crt]').that_subscribes_to(
              'File[x509_test.example.org_certificate]'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_crt').with(
            ensure: 'file',
            path: '/path/to/keyfile',
            )
          }
        end
        context 'when deploying a der cer certificate' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              type: 'cer'
            }
          end
          it { is_expected.to contain_exec('convert_test.example.org_to_cer').with(
            command: 'openssl x509 -outform der -in /etc/pki/tls/certs/test.example.org.pem -out /etc/pki/tls/certs/test.example.org.cer',
            path: '/usr/bin:/usr/sbin:/bin:/sbin',
            refreshonly: true,
            ).that_comes_before('File[x509_test.example.org_cer]').that_subscribes_to(
              'File[x509_test.example.org_certificate]'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cer').with(
            ensure: 'file',
            path: '/etc/pki/tls/certs/test.example.org.cer',
            )
          }
        end
        context 'when deploying a der der certificate' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              type: 'der'
            }
          end
          it { is_expected.to contain_exec('convert_test.example.org_to_der').with(
            command: 'openssl x509 -outform der -in /etc/pki/tls/certs/test.example.org.pem -out /etc/pki/tls/certs/test.example.org.der',
            path: '/usr/bin:/usr/sbin:/bin:/sbin',
            refreshonly: true,
            ).that_comes_before('File[x509_test.example.org_der]').that_subscribes_to(
              'File[x509_test.example.org_certificate]'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_der').with(
            ensure: 'file',
            path: '/etc/pki/tls/certs/test.example.org.der',
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
          it { is_expected.not_to contain_exec('convert_test.example.org_to_crt') }
          it { is_expected.to contain_file('x509_test.example.org_crt').with(
            ensure: 'absent',
            path: '/etc/pki/tls/certs/test.example.org.crt',
            )
          }
        end
      end
      context 'with default keymaster and preseeded certificate and predefined cert' do
        let :pre_condition do
          "include keymaster\n::keymaster::deploy::x509_cert { 'test.example.org': }"
        end
        context 'when present' do
          let :title do
            'test.example.org'
          end
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_exec('convert_test.example.org_to_crt').with(
            command: 'openssl x509 -outform der -in /etc/pki/tls/certs/test.example.org.pem -out /etc/pki/tls/certs/test.example.org.crt',
            path: '/usr/bin:/usr/sbin:/bin:/sbin',
            refreshonly: true,
            ).that_comes_before('File[x509_test.example.org_crt]').that_subscribes_to(
              'File[x509_test.example.org_certificate]'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_crt').with(
            ensure: 'file',
            path: '/etc/pki/tls/certs/test.example.org.crt',
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
          it { is_expected.not_to contain_exec('convert_test.example.org_to_crt') }
          it { is_expected.to contain_file('x509_test.example.org_crt').with(
            ensure: 'absent',
            path: '/etc/pki/tls/certs/test.example.org.crt',
            )
          }
        end
      end
    end
  end
end
