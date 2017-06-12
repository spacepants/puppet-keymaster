# keymaster::deploy::ssh_key_pair
#
# Deploys a key pair defined by the keymaster into a user's account on a node.
#
# @param $user User account to install the keys. Required.
# @param $filename Key filename. Required.
# @param $ensure Whether the keys should be present. Defaults to 'present'.
#
define keymaster::deploy::ssh_key_pair (
  String                    $user,
  String                    $filename,
  Enum['present', 'absent'] $ensure = 'present',
) {

  include ::keymaster::params

  if ! defined(User[$user]) {
    fail("The user '${user}' has not been defined in Puppet")
  }

  # get homedir and primary group of $user
  $home  = getparam(User[$user],'home')
  $group = getparam(User[$user],'gid')

  $clean_name = regsubst($name, '@', '_at_')
  $key_src_dir  = "${::keymaster::params::keystore_ssh}/${clean_name}"
  # filename of private key on the keymaster (source)
  $key_private_file = "${key_src_dir}/key"
  $key_public_file  = "${key_private_file}.pub"

  # filename of private key on the ssh client host (target)
  $key_tgt_file = "${home}/.ssh/${filename}"

  # read contents of key from the keymaster
  $key_public_content  = file($key_public_file, '/dev/null')
  $key_private_content = file($key_private_file, '/dev/null')


  # If 'absent', revoke the client keys
  if $ensure == 'absent' {
    file {[ $key_tgt_file, "${key_tgt_file}.pub" ]: ensure  => 'absent' }

  # test for homedir and primary group
  }
  elsif ! $home {
    notify{"ssh_keypair_${name}_did_not_run":
      message => "Can't determine home directory of user ${user}",
    }
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

    # Mangling all the non-true values for group
    # the choices were to force undefined or use $name
    # $name might be unpredictible... so undef
    if $group {
      $real_group = $group
    }
    else {
      warning("Can't determine primary group of user ${user}")
      $real_group = undef
    }

    # create client user's .ssh directory if not defined already
    if ! defined(File[ "${home}/.ssh" ]) {
      file { "${home}/.ssh":
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
      require => File["${home}/.ssh"],
    }

    file { "${key_tgt_file}.pub":
      ensure  => 'file',
      content => "${keytype} ${modulus} ${name}\n",
      owner   => $user,
      group   => $real_group,
      mode    => '0644',
      require => File["${home}/.ssh"],
    }

  }
  else {
    warning("Private key file ${key_private_file} for key ${name} not found on keymaster.")
  }
}
