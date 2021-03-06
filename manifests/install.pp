# keymaster::install
#
class keymaster::install {

  if $::keymaster::manage_gems {
    $gems = ['json', 'mixlib-cli', 'savon']

    $gems.each |$gem| {
      exec { "install ${gem}":
        command     => "gem install --no-ri --no-rdoc ${gem}",
        environment => $::keymaster::ruby_env,
        path        => "${::keymaster::ruby_path}:/usr/bin:/usr/sbin:/bin",
        unless      => "gem list | grep ${gem}",
      }
    }
  }

  file { '/usr/local/bin/cert-manager.rb':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/keymaster/cert-manager.rb',
  }
}
