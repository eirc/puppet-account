# == Class: account::user
#
# Creates users along with their groups, homedir and basic SSH configuration. Very useful to use as virtual resources in
# a common place for all the user and then realize them as needed in various nodes, classes etc.
#
# Inspired by:
# - https://github.com/icebourg/LC.tv-Puppet-Configuration/blob/master/classes/users.pp
# - http://blog.scottlowe.org/2012/11/25/using-puppet-for-account-management
#
# === Parameters
#
# [*uid*]
#   The user's uid. Mandatory argument. This can be a real pain in existing systems where changing a user's uid can
#   bring havoc, but that may be fixed in a later version since it's also very useful to keep the same uids across
#   systems.
#
# [*password*]
#   The user's password (as a hash). You can generate a password hash with `mkpasswd -m sha-512`.
#
# [*username*]
#   The username of the user. Defaults to the value of the title string.
#
# [*full_name*]
#   The full name of the user. Will be used as the user comment along with email Defaults to ''.
#
# [*email*]
#   The email of the user. Will be used as the user comment along with full_name and as the ssh_key comment (if one is
#   provided). Defaults to '/bin/bash'.
#
# [*shell*]
#   The prefered shell of the user. Defaults to '/bin/bash'.
#
# [*groups*]
#   Additional groups to add to the user. If empty will do nothing. Defaults to [].
#
# [*ssh_key*]
#   User's SSH key. If empty will do nothing. Defaults to ''.
#
# [*ssh_key_type*]
#   User's SSH key type. Only applied and mandatory when ssh_key is provided. Defaults to ''.
#
# === Examples
#
# Create a user called dude with uid 1000 and a password
#
#  account::user { 'dude':
#    uid      => 1000,
#    password => '<password hash>',
#  }
#
# Create a virtual resource for a user called 'dude'
#
#  @account::user { 'dude':
#    uid      => 1000,
#    password => '<password hash>',
#  }
#
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

  # Create the user's additional groups
  realize Account::Group[$groups]

  # Create the user's group
  account::group { $username:
    gid => $uid,
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
