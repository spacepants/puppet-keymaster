# keymaster::install
#
class keymaster::install {

  $gems = ['json', 'mixlib-cli', 'savon']

  $gems.each |$gem| {
    exec { "install ${gem}":
      command => "gem install --no-ri --no-rdoc ${gem}",
      path    => "${::keymaster::ruby_path}:/usr/bin:/usr/sbin:/bin",
      unless  => "gem list | grep ${gem}",
    }
  }

  file { '/usr/local/bin/cert-manager.rb':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/keymaster/cert-manager.rb',
  }
}
