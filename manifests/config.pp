# keymaster::config
#
class keymaster::config {

  $api_user = $::keymaster::api_user
  $api_pass = $::keymaster::api_pass
  $api_org  = $::keymaster::api_org
  $api_key  = $::keymaster::api_key

  # Set up Comodo API
  file { '/usr/local/etc':
    ensure => directory,
  } ->
  file { '/usr/local/etc/cert-manager.json':
    ensure  => file,
    mode    => '0640',
    owner   => $::keymaster::user,
    group   => $::keymaster::group,
    content => template('keymaster/cert-manager.json.erb'),
  }
}
