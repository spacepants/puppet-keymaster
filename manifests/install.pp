# keymaster::install
#
class keymaster::install {
  package { 'json':
    ensure   => installed,
    provider => gem,
  }
  package { 'mixlib-cli':
    ensure   => installed,
    provider => gem,
  }
  package { 'savon':
    ensure   => installed,
    provider => gem,
  }

  file { '/usr/local/bin/cert-manager.rb':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/keymaster/cert-manager.rb',
  }
}
