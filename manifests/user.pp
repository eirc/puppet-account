# Inspired by:
# - https://github.com/icebourg/LC.tv-Puppet-Configuration/blob/master/classes/users.pp
# - http://blog.scottlowe.org/2012/11/25/using-puppet-for-account-management
# You can generate a password hash with `mkpasswd -m sha-512`
define account::user (
  $uid,
  $password,
  $username     = $title,
  $full_name    = '',
  $email        = '',
  $shell        = '/bin/bash',
  $groups       = [ ],
  $ssh_key      = '',
  $ssh_key_type = '',
) {
  $homedir = "/home/${username}"
  $comment = "${full_name} <${email}>"

  realize Account::Group[$groups]

  # Create the user's group
  group { $username:
    ensure => present,
    gid    => $uid,
  }

  # Create the user
  user { $username:
    ensure     => present,
    password   => $password,
    uid        => $uid,
    gid        => $username,
    groups     => $groups,
    shell      => $shell,
    home       => $homedir,
    managehome => true,
    comment    => $comment,
    require    => [ Group[$username], Group[$groups] ],
  }

  # Make sure they have a home with proper permissions
  file { $homedir:
    ensure  => directory,
    owner   => $username,
    group   => $username,
    mode    => '0750',
    require => [ User[$username], Group[$username] ],
  }

  # And a place with the proper permissions for the SSH related configs
  file { "${homedir}/.ssh":
    ensure  => directory,
    owner   => $username,
    group   => $username,
    mode    => '0700',
    require => File[$homedir],
  }

  # And an authorized_keys file with proper permissions
  file { "${homedir}/.ssh/authorized_keys":
    ensure  => present,
    owner   => $username,
    group   => $username,
    mode    => '0600',
    require => File["${homedir}/.ssh"],
  }

  # If an ssh key was given add it
  if $ssh_key {
    if ! $email {
      fail('You must provide an email if you provide an ssh key!')
    }
    if ! $ssh_key_type {
      fail('You must provide an ssh key type if you provide an ssh key!')
    }

    ssh_authorized_key { $username:
      ensure  => present,
      key     => $ssh_key,
      type    => $ssh_key_type,
      user    => $username,
      require => File["${homedir}/.ssh/authorized_keys"],
    }
  }
}
