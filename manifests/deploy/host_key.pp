# keymaster::deploy::host_key
#
# Creates an ssh::server::host_key resource from a key pair on the keymaster.
#
# @param $ensure Whether the key should be present. Defaults to 'present'.
#
define keymaster::deploy::host_key (
  Enum['present', 'absent'] $ensure = 'present',
) {

  include ::keymaster::params
  include ::ssh

  $key_src_dir  = "${::keymaster::params::keystore_host_key}/${name}"
  # filename of private key on the keymaster (source)
  $key_private_file = "${key_src_dir}/key"
  $key_public_file  = "${key_src_dir}/key.pub"

  # read contents of key from the keymaster
  $key_public_content  = file($key_public_file, '/dev/null')
  $key_private_content = file($key_private_file, '/dev/null')

  if $ensure == 'absent' {
    # uh... let's not delete a host key. might be bad...

  }
  elsif ! $key_public_content or empty($key_public_content) {
    notify{"host_key_${name}_did_not_run":
      message => "Can't read public key ${key_public_file}",
    }
  }
  elsif ! $key_private_content or empty($key_private_content) {
    notify{"host_key_${name}_did_not_run":
      message => "Can't read private key ${key_private_file}",
    }
  }
  elsif ( $key_public_content =~ /^(ssh-...) (\S*)/ ) {
    # If syntax of pubkey checks out, install keypair on client
    $keytype = $1
    $modulus = $2

    ::ssh::server::host_key {$name:
      private_key_content => $key_private_content,
      public_key_content  => "${keytype} ${modulus} ${name}\n",
      before              => Concat['/etc/ssh/sshd_config'],
    }
  }
}
