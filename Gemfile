source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place, fake_version = nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

group :test do
  gem 'puppetlabs_spec_helper', '~> 2.0.1',                         :require => false
  gem 'rspec-puppet', '~> 2.5',                                     :require => false
  gem 'rspec-puppet-facts',                                         :require => false
  gem 'rspec-puppet-utils',                                         :require => false
  gem 'rspec_junit_formatter',                                      :require => false
  gem 'puppet-lint', '< 2.1.1',                                     :require => false
  gem 'puppet-lint-absolute_classname-check',                       :require => false
  gem 'puppet-lint-leading_zero-check',                             :require => false
  gem 'puppet-lint-trailing_comma-check',                           :require => false
  gem 'puppet-lint-version_comparison-check',                       :require => false
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check',  :require => false
  gem 'puppet-lint-unquoted_string-check',                          :require => false
  gem 'puppet-lint-variable_contains_upcase',                       :require => false
  gem 'metadata-json-lint', '~> 1.1.0',                             :require => false
  gem 'puppet-syntax',                                              :require => false, :git => 'https://github.com/gds-operations/puppet-syntax.git'
  gem 'rubocop', '~> 0.47.0',                                       :require => false
  gem 'rubocop-rspec', '~> 1.10.0',                                 :require => false
  gem 'rubocop-junit-formatter',                                    :require => false
  gem 'listen', '< 3.1.0',                                          :require => false
  gem 'deep_merge',                                                 :require => false
  gem 'json_pure', '< 2.0',                                         :require => false
  gem 'dotenv',                                                     :require => false
  gem 'simplecov',                                                  :require => false
end

group :development do
  gem 'guard-rake',   :require => false
end

group :system_tests do
  gem 'beaker', '< 3.1.0',             :require => false
  if beaker_version = ENV['BEAKER_VERSION']
    gem 'beaker', *location_for(beaker_version)
  end
  if beaker_rspec_version = ENV['BEAKER_RSPEC_VERSION']
    gem 'beaker-rspec', *location_for(beaker_rspec_version)
  else
    gem 'beaker-rspec', '< 6.0.0',  :require => false
  end
  gem 'beaker-puppet_install_helper',  :require => false
end



if facterversion = ENV['FACTER_GEM_VERSION']
gem 'facter', facterversion.to_s, :require => false, :groups => [:test]
else
gem 'facter', :require => false, :groups => [:test]
end

ENV['PUPPET_VERSION'].nil? ? puppetversion = '~> 4.0' : puppetversion = ENV['PUPPET_VERSION'].to_s
gem 'puppet', puppetversion, :require => false, :groups => [:test]