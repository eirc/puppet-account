account
=======

Helpers for managing users and groups with puppet.

Add users
---------

    account::user { 'dude':
      uid      => 1000,
      password => '<password hash>',
    }

More info in [user.pp](manifests/user.pp)

Add groups
----------

    account::group { 'admin':
      gid => 1000,
    }

More info in [group.pp](manifests/group.pp)

License
-------

Apache License, Version 2.0

Contact
-------

Eric Cohen <eirc.eirc@gmail.com>

Support
-------

Please log tickets and issues at our [Github issues page](https://github.com/eirc/puppet-account/issues)
