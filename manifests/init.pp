# keymaster
#
# Main class, includes all other classes.

# @param user Name of user for key management. Defaults to 'puppet'.
# @param group Name of group for key management. Defaults to 'puppet'.
# @param ruby_path Path to to use for ruby execs. Defaults to '/usr/bin:/usr/sbin:/bin:/usr/local/bin'.
# @param keystore_base Path to keystore base directory. Defaults to '/etc/puppetlabs/keymaster'.
# @param keystore_ssh Name of directory for ssh key storage. Defaults to 'ssh'.
# @param keystore_host_key Name of directory for host_key storage. Defaults to 'host_key'.
# @param keystore_x509 Name of directory for x509 storage. Defaults to 'x509'.
# @param api_user Username for InCommon cert manager API. Optional.
# @param api_pass Password for InCommon cert manager API. Optional.
# @param api_org Organization for InCommon cert manager API. Optional.
# @param api_key Secret key for InCommon cert manager API. Optional.
#
class keymaster (
  String           $user              = $::keymaster::params::user,
  String           $group             = $::keymaster::params::group,
  String           $ruby_path         = $::keymaster::params::ruby_path,
  String           $keystore_base     = $::keymaster::params::keystore_base,
  String           $keystore_ssh      = $::keymaster::params::keystore_ssh,
  String           $keystore_host_key = $::keymaster::params::keystore_host_key,
  String           $keystore_x509     = $::keymaster::params::keystore_x509,
  Boolean          $manage_gems       = true,
  Optional[Array]  $ruby_env          = undef,
  Optional[String] $api_user          = undef,
  Optional[String] $api_pass          = undef,
  Optional[String] $api_org           = undef,
  Optional[String] $api_key           = undef,
) inherits keymaster::params {

  # Set up directories for key storage
  file { 'key_store_base':
    ensure  => 'directory',
    path    => $keystore_base,
    owner   => $user,
    group   => $group,
    recurse => true,
    mode    => '0640',
  }

  file { 'key_store_ssh':
    ensure  => 'directory',
    path    => $keystore_ssh,
    owner   => $user,
    group   => $group,
    recurse => true,
    mode    => '0640',
  }

  file { 'key_store_host_key':
    ensure  => 'directory',
    path    => $keystore_host_key,
    owner   => $user,
    group   => $group,
    recurse => true,
    mode    => '0640',
  }

  file { 'key_store_x509':
    ensure  => 'directory',
    path    => $keystore_x509,
    owner   => $user,
    group   => $group,
    recurse => true,
    mode    => '0640',
  }

  class { '::keymaster::install': } ->
  class { '::keymaster::config': } ->
  Class['::keymaster']
}
