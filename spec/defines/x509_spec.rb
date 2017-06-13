require 'spec_helper'

describe 'keymaster::x509', type: :define do
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
          let(:title) {
            'test.example.org'
          }
          let(:params) {{
            common_name: 'test.example.org',
          }}
          it { is_expected.to contain_file('x509_test.example.org_dir').with(
            ensure: 'directory',
            path:   '/etc/puppetlabs/keymaster/x509/test.example.org',
            mode:   '0750',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/test.example.org/config.cnf',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_key').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/test.example.org/key.pem',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_csr').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/test.example.org/request.csr',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_pem').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/test.example.org/certificate.pem',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_id').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/test.example.org/id',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_renewid').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/test.example.org/renewid',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_exec('x509_test.example.org_key').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'openssl genrsa -out /etc/puppetlabs/keymaster/x509/test.example.org/key.pem 4096',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/test.example.org/key.pem',
            ).that_requires('File[x509_test.example.org_cnf]').that_comes_before(
              'File[x509_test.example.org_key]'
            )
          }
          it { is_expected.to contain_exec('x509_test.example.org_csr').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'openssl req -new -key /etc/puppetlabs/keymaster/x509/test.example.org/key.pem -out /etc/puppetlabs/keymaster/x509/test.example.org/request.csr -config /etc/puppetlabs/keymaster/x509/test.example.org/config.cnf',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/test.example.org/request.csr',
            ).that_requires('File[x509_test.example.org_key]').that_comes_before(
              'File[x509_test.example.org_csr]'
            )
          }
          it { is_expected.to contain_exec('x509_test.example.org_submit_csr').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'ruby cert-manager.rb --submit-csr --name test.example.org --aliases  --term 3',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/test.example.org/id',
            ).that_requires('File[x509_test.example.org_csr]').that_comes_before(
              'File[x509_test.example.org_id]'
            )
          }
          it { is_expected.to contain_exec('x509_test.example.org_pem').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'ruby cert-manager.rb --get-cert',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/test.example.org/certificate.pem',
            ).that_requires('File[x509_test.example.org_id]').that_comes_before(
              'File[x509_test.example.org_pem]'
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            %r{default_keyfile    = /etc/puppetlabs/keymaster/x509/test.example.org/key.pem}
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            /commonName             = test.example.org/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').without_content(
            /req_extensions     = req_aliases/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').without_content(
            /localityName           = /
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').without_content(
            /stateOrProvinceName    = /
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').without_content(
            /emailAddress           = /
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').without_content(
            /\[ req_aliases \]/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').without_content(
            /subjectAltName = "/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').without_content(
            /countryName            =/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').without_content(
            /organizationName       =/
            )
          }
        end
        context 'when absent' do
          let(:title) {
            'test.example.org'
          }
          let(:params) {{
            ensure:      'absent',
            common_name: 'test.example.org',
          }}
          it { is_expected.to contain_file('x509_test.example.org_dir').with_ensure('absent') }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_ensure('absent') }
          it { is_expected.to contain_file('x509_test.example.org_key').with_ensure('absent') }
          it { is_expected.to contain_file('x509_test.example.org_csr').with_ensure('absent') }
          it { is_expected.to contain_file('x509_test.example.org_pem').with_ensure('absent') }
          it { is_expected.not_to contain_exec('x509_test.example.org_key') }
          it { is_expected.not_to contain_exec('x509_test.example.org_csr') }
          it { is_expected.not_to contain_exec('x509_test.example.org_pem') }
        end
        context 'when customizing certificate configuration' do
          let :title do
            'test.example.org'
          end
          let :params do
            {
              country:      'US',
              common_name:  'test.example.org',
              organization: 'Test Example Organization',
              state:        'Texas',
              locality:     'Austin',
              aliases:      ['first', 'second', 'third'],
              email:        'test@example.com',
              days:         '790',
              self_signed:   true,
            }
          end
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            %r{default_keyfile    = /etc/puppetlabs/keymaster/x509/test.example.org/key.pem}
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            /commonName             = test.example.org/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            /countryName            = US/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            /organizationName       = Test Example Organization/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            /req_extensions     = req_aliases/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            /localityName           = Austin/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            /stateOrProvinceName    = Texas/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            /emailAddress           = test@example.com/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            /\[ req_aliases \]/
            )
          }
          it { is_expected.to contain_file('x509_test.example.org_cnf').with_content(
            /subjectAltName = "DNS: first, DNS: second, DNS: third"/
            )
          }
        end
        context 'when using a self-signed certificate' do
          let :title do
            'test.example.org'
          end
          let(:params) {{
            ensure:      'present',
            common_name: 'test.example.org',
            self_signed: true,
          }}

          it { is_expected.not_to contain_exec('x509_test.example.org_submit_csr') }
          it { is_expected.not_to contain_file('x509_test.example.org_id') }
          it { is_expected.not_to contain_file('x509_test.example.org_renewid') }

          it { is_expected.to contain_exec('x509_test.example.org_key').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'openssl genrsa -out /etc/puppetlabs/keymaster/x509/test.example.org/key.pem 4096',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/test.example.org/key.pem',
            ).that_requires('File[x509_test.example.org_cnf]').that_comes_before(
              'File[x509_test.example.org_key]'
            )
          }
          it { is_expected.to contain_exec('x509_test.example.org_csr').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'openssl req -new -key /etc/puppetlabs/keymaster/x509/test.example.org/key.pem -out /etc/puppetlabs/keymaster/x509/test.example.org/request.csr -config /etc/puppetlabs/keymaster/x509/test.example.org/config.cnf',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/test.example.org/request.csr',
            ).that_requires('File[x509_test.example.org_key]').that_comes_before(
              'File[x509_test.example.org_csr]'
            )
          }
          it { is_expected.to contain_exec('x509_test.example.org_pem').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'openssl x509 -req -days 365 -in /etc/puppetlabs/keymaster/x509/test.example.org/request.csr -signkey /etc/puppetlabs/keymaster/x509/test.example.org/key.pem -out /etc/puppetlabs/keymaster/x509/test.example.org/certificate.pem',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/test.example.org/certificate.pem',
            ).that_requires('File[x509_test.example.org_csr]').that_comes_before(
              'File[x509_test.example.org_pem]'
            )
          }
        end
        context 'when generating a wildcard certificate' do
          let(:title) {
            '*.example.org'
          }
          let(:params) {{
            common_name: '*.example.org',
          }}
          it { is_expected.to contain_file('x509_wild.example.org_dir').with(
            ensure: 'directory',
            path:   '/etc/puppetlabs/keymaster/x509/wild.example.org',
            mode:   '0750',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/wild.example.org/config.cnf',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_key').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/wild.example.org/key.pem',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_csr').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/wild.example.org/request.csr',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_pem').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/wild.example.org/certificate.pem',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_id').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/wild.example.org/id',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_renewid').with(
            ensure: 'file',
            path:   '/etc/puppetlabs/keymaster/x509/wild.example.org/renewid',
            mode:   '0640',
            owner:  'puppet',
            group:  'puppet'
            )
          }
          it { is_expected.to contain_exec('x509_wild.example.org_key').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'openssl genrsa -out /etc/puppetlabs/keymaster/x509/wild.example.org/key.pem 4096',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/wild.example.org/key.pem',
            ).that_requires('File[x509_wild.example.org_cnf]').that_comes_before(
              'File[x509_wild.example.org_key]'
            )
          }
          it { is_expected.to contain_exec('x509_wild.example.org_csr').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'openssl req -new -key /etc/puppetlabs/keymaster/x509/wild.example.org/key.pem -out /etc/puppetlabs/keymaster/x509/wild.example.org/request.csr -config /etc/puppetlabs/keymaster/x509/wild.example.org/config.cnf',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/wild.example.org/request.csr',
            ).that_requires('File[x509_wild.example.org_key]').that_comes_before(
              'File[x509_wild.example.org_csr]'
            )
          }
          it { is_expected.to contain_exec('x509_wild.example.org_submit_csr').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'ruby cert-manager.rb --submit-csr --name *.example.org --aliases  --term 3',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/wild.example.org/id',
            ).that_requires('File[x509_wild.example.org_csr]').that_comes_before(
              'File[x509_wild.example.org_id]'
            )
          }
          it { is_expected.to contain_exec('x509_wild.example.org_pem').with(
            path:    '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
            command: 'ruby cert-manager.rb --get-cert',
            user:    'puppet',
            group:   'puppet',
            creates: '/etc/puppetlabs/keymaster/x509/wild.example.org/certificate.pem',
            ).that_requires('File[x509_wild.example.org_id]').that_comes_before(
              'File[x509_wild.example.org_pem]'
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').with_content(
            %r{default_keyfile    = /etc/puppetlabs/keymaster/x509/wild.example.org/key.pem}
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').with_content(
            /commonName             = \*.example.org/
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').without_content(
            /req_extensions     = req_aliases/
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').without_content(
            /localityName           = /
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').without_content(
            /stateOrProvinceName    = /
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').without_content(
            /emailAddress           = /
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').without_content(
            /\[ req_aliases \]/
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').without_content(
            /subjectAltName = "/
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').without_content(
            /countryName            =/
            )
          }
          it { is_expected.to contain_file('x509_wild.example.org_cnf').without_content(
            /organizationName       =/
            )
          }
        end
      end
    end
  end
end
