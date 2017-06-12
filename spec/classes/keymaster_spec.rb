require 'spec_helper'

describe 'keymaster' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'keymaster class without any parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('keymaster') }
        it { is_expected.to contain_class('keymaster::params') }
        it { is_expected.to contain_class('keymaster::install').that_comes_before('Class[keymaster::config]') }
        it { is_expected.to contain_class('keymaster::config') }

        it { is_expected.to contain_file('key_store_base').with(
          ensure:   'directory',
          path:     '/etc/puppetlabs/keymaster',
          owner:    'puppet',
          group:    'puppet',
          recurse:  true,
          mode:     '0640',
          )
        }
        it { is_expected.to contain_file('key_store_ssh').with(
          ensure:   'directory',
          path:     '/etc/puppetlabs/keymaster/ssh',
          owner:    'puppet',
          group:    'puppet',
          recurse:  true,
          mode:     '0640',
          )
        }
        it { is_expected.to contain_file('key_store_host_key').with(
          ensure:   'directory',
          path:     '/etc/puppetlabs/keymaster/host_key',
          owner:    'puppet',
          group:    'puppet',
          recurse:  true,
          mode:     '0640',
          )
        }
        it { is_expected.to contain_file('key_store_x509').with(
          ensure:   'directory',
          path:     '/etc/puppetlabs/keymaster/x509',
          owner:    'puppet',
          group:    'puppet',
          recurse:  true,
          mode:     '0640',
          )
        }

        it { is_expected.to contain_package('json').with(
          ensure:   'installed',
          provider: 'gem',
          )
        }
        it { is_expected.to contain_package('mixlib-cli').with(
          ensure:   'installed',
          provider: 'gem',
          )
        }
        it { is_expected.to contain_package('savon').with(
          ensure:   'installed',
          provider: 'gem',
          )
        }
        it { is_expected.to contain_file('/usr/local/bin/cert-manager.rb').with(
          ensure: 'file',
          mode:   '0755',
          source: 'puppet:///modules/keymaster/cert-manager.rb',
          )
        }

        it { is_expected.to contain_file('/usr/local/etc').with_ensure('directory') }
        it { is_expected.to contain_file('/usr/local/etc/cert-manager.json').with(
          ensure: 'file',
          mode:   '0640',
          owner:  'puppet',
          group:  'puppet',
          ).that_requires('File[/usr/local/etc]')
        }
      end
      context 'keymaster class with parameter overrides' do
        let(:params) {{
          user: 'specuser',
          group: 'specgroup',
          keystore_base: '/path/to/keystore',
          keystore_ssh: '/path/to/keystore/specsshdir',
          keystore_host_key: '/path/to/keystore/spechostkeydir',
          keystore_x509: '/path/to/keystore/specx509dir',
          api_user: 'specapiuser',
          api_pass: 'specapigroup',
          api_org: 'specapiorg',
          api_key: 'specapikey',
        }}

        it { is_expected.to contain_file('key_store_base').with(
          ensure:   'directory',
          path:     '/path/to/keystore',
          owner:    'specuser',
          group:    'specgroup',
          recurse:  true,
          mode:     '0640',
          )
        }
        it { is_expected.to contain_file('key_store_ssh').with(
          ensure:   'directory',
          path:     '/path/to/keystore/specsshdir',
          owner:    'specuser',
          group:    'specgroup',
          recurse:  true,
          mode:     '0640',
          )
        }
        it { is_expected.to contain_file('key_store_host_key').with(
          ensure:   'directory',
          path:     '/path/to/keystore/spechostkeydir',
          owner:    'specuser',
          group:    'specgroup',
          recurse:  true,
          mode:     '0640',
          )
        }
        it { is_expected.to contain_file('key_store_x509').with(
          ensure:   'directory',
          path:     '/path/to/keystore/specx509dir',
          owner:    'specuser',
          group:    'specgroup',
          recurse:  true,
          mode:     '0640',
          )
        }
        it { is_expected.to contain_file('/usr/local/etc/cert-manager.json').with(
          ensure: 'file',
          mode:   '0640',
          owner:  'specuser',
          group:  'specgroup',
          ).that_requires('File[/usr/local/etc]').with_content(
            /\"username\": \"specapiuser\",\n  \"password\": \"specapigroup\",\n  \"orgid\": \"specapiorg\",\n  \"secret\": \"specapikey\"/
          )
        }
      end
    end
  end
end
