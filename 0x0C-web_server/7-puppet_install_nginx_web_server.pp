# 7-puppet_install_nginx_web_server.pp
# Puppet manifest to install and configure Nginx with a custom root page and 301 redirect

package { 'nginx':
  ensure => installed,
}

service { 'nginx':
  ensure     => running,
  enable     => true,
  hasstatus  => true,
  hasrestart => true,
}

file { '/var/www/html/index.nginx-debian.html':
  ensure  => file,
  content => "Hello World!\n",
  require => Package['nginx'],
}

file { '/etc/nginx/sites-available/default':
  ensure  => file,
  content => template('nginx/default.erb'),
  notify  => Service['nginx'],
}
