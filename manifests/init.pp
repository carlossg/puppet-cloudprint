class cloudprint(
  $username,
  $password,
  $connector,
  $server = 'http://localhost:631') {

  file { '/etc/cloudprint':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  } ->

  file { '/etc/cloudprint/generate_cloudprint_config.py':
    ensure => present,
    source => 'puppet:///modules/cloudprint/generate_cloudprint_config.py',
    mode   => '0755',
  } ->

  exec { "/etc/cloudprint/generate_cloudprint_config.py ${username} ${password} ${connector} ${server}":
    cwd     => '/etc/cloudprint',
    creates => "/etc/cloudprint/${connector}.conf",
  } ->

  file { '/etc/cloudprint/Service State':
    ensure  => present,
    source  => "/etc/cloudprint/${connector}.conf",
    mode    => '0600',
    replace => false,
  } ->

  file { '/etc/init.d/cloudprintproxy':
    ensure => present,
    source => 'puppet:///modules/cloudprint/cloudprintproxy.sh',
    mode   => '0755',
  } ->

  service { 'cloudprintproxy':
    ensure => running,
    enable => true,
  }
}
