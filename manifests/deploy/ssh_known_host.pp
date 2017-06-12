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
  Array[String]             $aliases = [],
) {

  include ::keymaster::params

  $key_src_dir  = "${::keymaster::params::keystore_host_key}/${name}"
  # filename of public key on the keymaster (source)
  $key_public_file  = "${key_src_dir}/key.pub"

  # read contents of key from the keymaster
  $key_public_content  = file($key_public_file, '/dev/null')

  # get homedir of $user
  $home  = getparam(User[$user],'home')
  $group = getparam(User[$user],'gid')

  if ! $home {
    notify{"ssh_knownhost_${name}_did_not_run":
      message => "Can't determine home directory of user ${user}",
    }
  }
  elsif ! $key_public_content or empty($key_public_content) {
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
      $real_path = "${home}/.ssh/known_hosts"

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

      if $ensure == 'present' {
        # create client user's .ssh directory if not defined already
        if ! defined(File[ "${home}/.ssh" ]) {
          file { "${home}/.ssh":
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
    warning("Private key file ${key_public_file} for key ${name} not found on keymaster.")
  }
}
