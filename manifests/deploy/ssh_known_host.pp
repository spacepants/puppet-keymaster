# keymaster::deploy::ssh_known_host
#
# Installs a known host key into either a server user's known_hosts file or a specified path.
#
# @param $user User account to install the key. Optional.
# @param $ensure Whether the key should be present. Defaults to 'present'.
# @param $path A specific path to the desired known_hosts file. Optional.
# @param $aliases Any aliases the host might have. Optional.
#
define keymaster::deploy::ssh_known_host (
  String                    $user,
  Enum['present', 'absent'] $ensure  = 'present',
  Optional[String]          $path    = undef,
  Optional[String]          $group = undef,
  Optional[String]          $home = undef,
  Array[String]             $aliases = [],
  Boolean                   $user_enforce = true,
) {

  include ::keymaster::params

  if !defined(User[$user]) and $user_enforce {
    fail("The user '${user}' has not been defined in Puppet")
  }

  $key_src_dir  = "${::keymaster::params::keystore_host_key}/${name}"
  # filename of public key on the keymaster (source)
  $key_public_file  = "${key_src_dir}/key.pub"

  # read contents of key from the keymaster
  $key_public_content  = file($key_public_file, '/dev/null')

  # get homedir of $user
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

  if ! $key_public_content or empty($key_public_content) {
    notify{"ssh_knownhost_${name}_did_not_run":
      message => "Can't read public key ${key_public_file}",
    }
  }
  elsif ( $key_public_content =~ /^(ssh-...) (\S*)/ ) {
    # If syntax of pubkey checks out, install keypair on client
    $keytype = $1
    $modulus = $2

    if $path {
      $real_path = $path
    }
    else {
      $real_path = "${real_home}/.ssh/known_hosts"

      if $ensure == 'present' {
        # create client user's .ssh directory if not defined already
        if ! defined(File[ "${real_home}/.ssh" ]) {
          file { "${real_home}/.ssh":
            ensure => 'directory',
            owner  => $user,
            group  => $real_group,
            mode   => '0700',
          }
        }
      }
    }
    sshkey { "${user}_${name}":
      ensure       => $ensure,
      name         => $name,
      host_aliases => $aliases,
      key          => $modulus,
      target       => $real_path,
      type         => $keytype,
    }
  }
  else {
    warning("Public key file ${key_public_file} for key ${name} not found on keymaster.")
  }
}
