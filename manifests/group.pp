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
