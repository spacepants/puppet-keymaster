# keymaster::deploy::ssh_key_pair
#
# Deploys a key pair defined by the keymaster into a user's account on a node.
#
# @param $user User account to install the keys. Required.
# @param $filename Key filename. Required.
# @param $ensure Whether the keys should be present. Defaults to 'present'.
# @param $user_enforce Whether to enforce a defined user in the catalog. Defaults to true.
#
define keymaster::deploy::ssh_key_pair (
  String                    $user,
  String                    $filename,
  Optional[String]          $group = undef,
  Optional[String]          $home = undef,
  Enum['present', 'absent'] $ensure = 'present',
  Boolean                   $user_enforce = true,
) {

  include ::keymaster::params

  if !defined(User[$user]) and $user_enforce {
    fail("The user '${user}' has not been defined in Puppet")
  }

  # get homedir and primary group of $user
  if $home {
    $real_home = $home
  }
  else {
    $real_home = "/home/${user}"
  }

  if $group {
    $real_group = $group
  }
  else {
    $real_group = $user
  }

  $clean_name = regsubst($name, '@', '_at_')
  $key_src_dir  = "${::keymaster::params::keystore_ssh}/${clean_name}"
  # filename of private key on the keymaster (source)
  $key_private_file = "${key_src_dir}/key"
  $key_public_file  = "${key_private_file}.pub"

  # filename of private key on the ssh client host (target)
  $key_tgt_file = "${real_home}/.ssh/${filename}"

  # read contents of key from the keymaster
  $key_public_content  = file($key_public_file, '/dev/null')
  $key_private_content = file($key_private_file, '/dev/null')


  # If 'absent', revoke the client keys
  if $ensure == 'absent' {
    file {[ $key_tgt_file, "${key_tgt_file}.pub" ]: ensure  => 'absent' }
  }
  elsif ! $key_public_content or empty($key_public_content) {
    notify{"ssh_keypair_${name}_did_not_run":
      message => "Can't read public key ${key_public_file}",
    }
  }
  elsif ! $key_private_content or empty($key_private_content) {
    notify{"ssh_keypair_${name}_did_not_run":
      message => "Can't read private key ${key_private_file}",
    }
  }
  elsif ( $key_public_content =~ /^(ssh-...) (\S*)/ ) {
    # If syntax of pubkey checks out, install keypair on client
    $keytype = $1
    $modulus = $2

    # create client user's .ssh directory if not defined already
    if ! defined(File[ "${real_home}/.ssh" ]) {
      file { "${real_home}/.ssh":
        ensure => 'directory',
        owner  => $user,
        group  => $real_group,
        mode   => '0700',
      }
    }

    file { $key_tgt_file:
      ensure  => 'file',
      content => $key_private_content,
      owner   => $user,
      group   => $real_group,
      mode    => '0600',
      require => File["${real_home}/.ssh"],
    }

    file { "${key_tgt_file}.pub":
      ensure  => 'file',
      content => "${keytype} ${modulus} ${name}\n",
      owner   => $user,
      group   => $real_group,
      mode    => '0644',
      require => File["${real_home}/.ssh"],
    }

  }
  else {
    warning("Private key file ${key_private_file} for key ${name} not found on keymaster.")
  }
}
