# keymaster::deploy::x509_cert::p12
#
# Converts a deployed x509 PEM certificate to a PKCS12 certificate on a node.
#
# @param $ensure Whether the cert should be present. Defaults to 'present'.
# @param $type Format for the cert file. Defaults to 'p12'.
# @param $path Absolute path for the cert file. Optional.
# @param $owner File owner for the cert file. Optional.
# @param $group File group for the cert file. Optional.
# @param $pass Pass phrase for the cert file. Optional.
# @param $key Should the p12 cert include the key. Defaults to true.
#
define keymaster::deploy::x509_cert::p12 (
  Enum['present', 'absent'] $ensure = 'present',
  Enum['p12','pfx']         $type   = 'p12',
  Optional[String]          $path   = undef,
  Optional[String]          $owner  = undef,
  Optional[String]          $group  = undef,
  Optional[String]          $pass   = undef,
  Boolean                   $key    = true,
) {

  # include the pem cert if it isn't already
  if !defined(Keymaster::Deploy::X509_cert[$name]) {
    ::keymaster::deploy::x509_cert { $name:
      ensure => $ensure,
    }
  }

  include ::keymaster::params

  if $path {
    $real_path = $path
  }
  else {
    $real_path = "${::keymaster::params::x509_cert_dir}/${name}.${type}"
  }
  $pem_path = "${::keymaster::params::x509_cert_dir}/${name}.pem"

  if $key {
    $key_opt = "-inkey ${::keymaster::params::x509_key_dir}/${name}.key"

    # include the key if it isn't already
    if !defined(Keymaster::Deploy::X509_key[$name]) {
      ::keymaster::deploy::x509_key { $name:
        ensure => $ensure,
      }
    }
  }
  else {
    $key_opt = '-nokeys'
  }

  if $pass {
    $pass_opt = "-passout pass:${pass}"
  }
  else {
    $pass_opt = ''
  }

  if $ensure == 'present' {
    $file_ensure = 'file'
  }
  else {
    $file_ensure = 'absent'
  }

  if !defined(File["x509_${name}_certificate"]) {
    notify{"x509_${name}_p12_cert_did_not_run":
      message => "Certificate file for ${name} unavailable",
    }
  }
  else {
    if $ensure == 'present' {
      exec { "convert_${name}_to_${type}":
        command     => "openssl pkcs12 -export -out ${real_path} -in ${pem_path} ${key_opt} ${pass_opt}",
        path        => '/usr/bin:/usr/sbin:/bin:/sbin',
        refreshonly => true,
        before      => File["x509_${name}_${type}"],
        subscribe   => [
          File["x509_${name}_certificate"],
          File["x509_${name}_private_key"],
        ],
      }
    }

    file{"x509_${name}_${type}":
      ensure => $file_ensure,
      path   => $real_path,
    }
  }
}
