# Configures Nginx to include a custom HTTP header "X-Served-By" using Puppet

package { 'nginx':
  ensure => installed,
}

service { 'nginx':
  ensure => running,
  enable => true,
  require => Package['nginx'],
}

file_line { 'add_custom_header':
  path  => '/etc/nginx/sites-available/default',
  line  => 'add_header X-Served-By $hostname;',
  match => 'add_header X-Served-By',
  notify => Service['nginx'],
  require => Package['nginx'],
}
