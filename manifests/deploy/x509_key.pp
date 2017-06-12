# keymaster::deploy::x509_key
#
# Deploys an x509 key defined by the keymaster to a file resource on a node.
#
# @param $ensure Whether the key should be present. Defaults to 'present'.
# @param $path Absolute path for the key file. Optional.
# @param $owner File owner for the key file. Optional.
# @param $group File group for the key file. Optional.
#
define keymaster::deploy::x509_key (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[String]          $path   = undef,
  Optional[String]          $owner  = undef,
  Optional[String]          $group  = undef,
) {

  include ::keymaster::params

  case $ensure {
    'present': {
      $file_ensure = 'file'
    }
    default: {
      $file_ensure = 'absent'
    }
  }

  $key_src_dir  = "${::keymaster::params::keystore_x509}/${name}"
  # filename of private key on the keymaster (source)
  $key_file = "${key_src_dir}/key.pem"

  # read contents of key from the keymaster
  $key_content  = file($key_file, '/dev/null')

  if !$key_content or empty($key_content) {
    notify{"x509_${name}_key_did_not_run":
      message => "Can't read key ${key_file}",
    }
  }
  else {

    if $path {
      # keep a copy of the key in the local keystore
      file {"x509_${name}_key":
        ensure  => $file_ensure,
        path    => "${::keymaster::params::x509_key_dir}/${name}.pem",
        mode    => '0640',
        content => $key_content,
      }
      file {"x509_${name}_private_key":
        ensure  => $file_ensure,
        path    => $path,
        owner   => $owner,
        group   => $owner,
        mode    => '0640',
        content => $key_content,
      }
    }
    else {
      file {"x509_${name}_private_key":
        ensure  => $file_ensure,
        path    => "${::keymaster::params::x509_key_dir}/${name}.pem",
        owner   => $owner,
        group   => $owner,
        mode    => '0640',
        content => $key_content,
      }
    }
  }
}
