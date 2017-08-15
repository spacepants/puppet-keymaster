# keymaster::deploy::x509_cert::der
#
# Converts a predefined x509 certificate to a DER encoded x509 certificate on a node.
#
# @param $ensure Whether the cert should be present. Defaults to 'present'.
# @param $type Format for the cert file. Defaults to 'crt'.
# @param $path Absolute path for the cert file. Optional.
# @param $owner File owner for the cert file. Optional.
# @param $group File group for the cert file. Optional.
#
define keymaster::deploy::x509_cert::der (
  Enum['present', 'absent'] $ensure = 'present',
  Enum['cer','crt','der']   $type   = 'crt',
  Optional[String]          $path   = undef,
  Optional[String]          $owner  = undef,
  Optional[String]          $group  = undef,
) {

  include ::keymaster::params

  # include the pem cert if it isn't already
  if !defined(Keymaster::Deploy::X509_cert[$name]) {
    ::keymaster::deploy::x509_cert { $name:
      ensure => $ensure,
    }
  }

  if $path {
    $real_path = $path
  }
  else {
    $real_path = "${::keymaster::params::x509_cert_dir}/${name}.${type}"
  }

  $pem_path = "${::keymaster::params::x509_cert_dir}/${name}.pem"

  if $ensure == 'present' {
    $file_ensure = 'file'
  }
  else {
    $file_ensure = 'absent'
  }

  if !defined(File["x509_${name}_certificate"]) {
    notify{"x509_${name}_der_cert_did_not_run":
      message => "Certificate file for ${name} unavailable",
    }
  }
  else {
    if $ensure == 'present' {
      exec { "convert_${name}_to_${type}":
        command     => "openssl x509 -outform der -in ${pem_path} -out ${real_path}",
        path        => '/usr/bin:/usr/sbin:/bin:/sbin',
        refreshonly => true,
        subscribe   => File["x509_${name}_certificate"],
        before      => File["x509_${name}_${type}"],
      }
    }

    file{"x509_${name}_${type}":
      ensure => $file_ensure,
      path   => $real_path,
    }
  }
}
