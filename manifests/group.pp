# == Class: account::group
#
# Creates groups with optional gids. Very useful to use with virtual resources in a common place for all the groups and
# then realize them as needed in various nodes, classes etc. Compatible with a user's additional groups where all of
# them will be required and realized automatically.
#
# === Parameters
#
# [*groupname*]
#   The name of the group. Defaults to the value of the title string.
#
# [*gid*]
#   The gid to enforce on the group. If empty will do nothing. Defaults to ''.
#
# === Examples
#
# Create a group called admin with gid 1000
#
#  account::group { 'admin':
#    gid => 1000,
#  }
#
# Create a group called admin with any gid
#
#  account::group { 'admin': }
#
# Create a virtual resource for a group called 'admin'
#
#  @account::group { 'admin': }
#
define account::group (
  $groupname = $title,
  $gid       = '',
) {

  if $gid {
    group { $groupname:
      ensure => present,
      gid    => $gid,
    }
  } else {
    group { $groupname:
      ensure => present,
    }
  }
}
