# keymaster::deploy::x509_cert
#
# Deploys an x509 certificate defined by the keymaster to a file resource on a node.
#
# @param $ensure Whether the cert should be present. Defaults to 'present'.
# @param $type Format for the cert file. Defaults to 'pem'.
# @param $path Absolute path for the cert file. Optional.
# @param $owner File owner for the cert file. Optional.
# @param $group File group for the cert file. Optional.
#
define keymaster::deploy::x509_cert (
  Enum['present', 'absent']                 $ensure = 'present',
  Enum['pem','cer','crt','der','p12','pfx'] $type   = 'pem',
  Optional[String]                          $path   = undef,
  Optional[String]                          $owner  = undef,
  Optional[String]                          $group  = undef,
) {

  include ::keymaster::params

  if $ensure == 'present' {
    $file_ensure = 'file'
  }
  else {
    $file_ensure = 'absent'
  }

  if $owner or $group {
    $file_mode = '0640'
  }
  else {
    $file_mode = '0644'
  }

  if $path {
    $real_path = $path
  }
  else {
    $real_path = "${::keymaster::params::x509_cert_dir}/${name}"
  }

  $cert_src_dir  = "${::keymaster::params::keystore_x509}/${name}"
  $pem_path = "${::keymaster::params::x509_cert_dir}/${name}.pem"

  # read contents of key from the keymaster
  $cert_file = "${cert_src_dir}/certificate.pem"
  $cert_content  = file($cert_file, '/dev/null')

  if ! $cert_content or empty($cert_content) {
    notify{"x509_${name}_cert_did_not_run":
      message => "Can't read certificate ${cert_file}",
    }
  }
  else {
    file {"x509_${name}_certificate":
      ensure  => $file_ensure,
      path    => "${::keymaster::params::x509_cert_dir}/${name}.pem",
      owner   => $owner,
      group   => $owner,
      content => $cert_content,
    }

    case $type {
      'crt','cer','der': {
        # pass params onto der type
        if !defined(Keymaster::Deploy::X509_cert::Der[$name]) {
          ::keymaster::deploy::x509_cert::der { $name:
            ensure => $ensure,
            type   => $type,
            path   => $path,
            owner  => $owner,
            group  => $group,
          }
        }
      }
      'p12', 'pfx': {
        # pass params onto p12 type
        if !defined(Keymaster::Deploy::X509_cert::P12[$name]) {
          ::keymaster::deploy::x509_cert::p12 { $name:
            ensure => $ensure,
            type   => $type,
            path   => $path,
            owner  => $owner,
            group  => $group,
          }
        }
      }
      default: {
        # cert defaults to pem format
        if $path {
          file {"x509_${name}_pem_certificate":
            ensure  => $file_ensure,
            path    => $path,
            mode    => $file_mode,
            owner   => $owner,
            group   => $owner,
            content => $cert_content,
          }
        }
      }
    }
  }

}
