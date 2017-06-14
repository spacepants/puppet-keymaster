# keymaster::params
#
# This class sets variables according to platform.
#
class keymaster::params {

  $keystore_base     = '/etc/puppetlabs/keymaster'
  $keystore_ssh      = "${keystore_base}/ssh"
  $keystore_host_key = "${keystore_base}/host_key"
  $keystore_x509     = "${keystore_base}/x509"
  $ruby_path         = '/usr/local/bin'
  $user              = 'puppet'
  $group             = 'puppet'

  case $::osfamily {
    'RedHat':{
      $x509_key_dir  = '/etc/pki/tls/private'
      $x509_cert_dir = '/etc/pki/tls/certs'
    }
    default:{
      fail("The keymaster Puppet module does not support ${::osfamily} family of operating systems")
    }
  }
}
