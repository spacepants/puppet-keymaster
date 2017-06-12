# keymaster::host_key
#
# Manages the creation, generation, and deletion of host keys on the keymaster
#
# @param $ensure Whether the key should be present. Defaults to 'present'.
# @param $keytype Key type (rsa or dsa) to create. Defaults to 'rsa'.
# @param $length Key length to ensure. Defaults to '2048'.
# @param $prefix String prefix for the directory in the key store. Optional.
# @param $maxdays Maximum number of days for the key to exist before regeneration. Optional.
# @param $mindate Minimum allowed date (e.g., '2017-05-30') for the key. Keys created before this date will be regenerated. Optional.
# @param $force Force key regeneration. Defaults to false.
#
define keymaster::host_key (
  Enum['present', 'absent'] $ensure  = 'present',
  Enum['dsa', 'rsa']        $keytype = 'rsa',
  String                    $length  = '2048',
  Optional[String]          $prefix  = undef,
  Optional[String]          $maxdays = undef,
  Optional[String]          $mindate = undef,
  Boolean                   $force   = false,
) {

  # dsa keys are always 1024
  if $keytype == 'dsa' {
    $real_length = '1024'
  }
  else {
    $real_length = $length
  }

  # $valid_name = assert_type(Regexp[/^[A-Za-z0-9][A-Za-z0-9_.:@-]+$/], $name) |$expected, $actual| {
  #   fail("${actual} must start with a letter or digit, and may only contain the characters A-Za-z0-9_.:@-")
  #   'invalid'
  # }

  if $prefix {
    $key_dir = "${::keymaster::keystore_host_key}/${prefix}_${name}"
  }
  else {
    $key_dir = "${::keymaster::keystore_host_key}/${name}"
  }

  $key_private_file = "${key_dir}/key"
  $key_public_file  = "${key_dir}/key.pub"

  # Set resource defaults
  Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }

  File {
    owner => $::keymaster::user,
    group => $::keymaster::group,
    mode  => '0600',
  }

  file { "host_key_${name}_dir":
    ensure => directory,
    path   => $key_dir,
    mode   => '0644',
  }

  file { "host_key_${name}_key":
    ensure => $ensure,
    path   => $key_private_file,
  }

  file { "host_key_${name}_pub":
    ensure => $ensure,
    path   => $key_public_file,
  }

  if $ensure == 'present' {
  # Remove the existing key pair, if
  # * $force is true, or
  # * $maxdays or $mindate criteria aren't met, or
  # * $keytype or $length have changed
    $keycontent = file($key_public_file, '/dev/null')
    if $keycontent {
      if $force {
        $reason = 'force=true'
      }
      elsif $mindate and generate('/usr/bin/find', $key_private_file, '!', '-newermt', $mindate) {
        $reason = "created before ${mindate}"
      }
      elsif $maxdays and generate('/usr/bin/find', $key_private_file, '-mtime', "+${maxdays}") {
        $reason = "older than ${maxdays} days"
      }
      elsif $keycontent =~ /^ssh-... [^ ]+ (...) (\d+)$/  {
        if $keytype != $1 {
          $reason = "keytype changed: $1 -> ${keytype}" # lint:ignore:variables_not_enclosed
        } else {
          if $length != $2 {
            $reason = "length changed: $2 -> ${length}" # lint:ignore:variables_not_enclosed
          }
        }
      }

      if defined('$reason') {
        exec { "Revoke previous key ${name}: ${reason}":
          command => "rm ${key_private_file} ${key_public_file}",
          before  => Exec["Create key ${name}: ${keytype}, ${length} bits"],
        }
      }
    }

    # Create the key pair.
    # We "repurpose" the comment field in public keys on the keymaster to
    # store data about the key, i.e. $keytype and $length.  This avoids
    # having to rerun ssh-keygen -l on every key at every run to determine
    # the key length.
    exec { "Create key ${name}: ${keytype}, ${real_length} bits":
      command => "ssh-keygen -t ${keytype} -b ${real_length} -f ${key_private_file} -C '${keytype} ${real_length}' -N ''",
      user    => $::keymaster::user,
      group   => $::keymaster::group,
      creates => $key_private_file,
      before  => [ File["host_key_${name}_key","host_key_${name}_pub"] ],
      require => File["host_key_${name}_dir"],
    }
  }
}
