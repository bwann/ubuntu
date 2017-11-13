Ubuntu tinkerings
-----------------

Things I've written or acquired to help manager Ubuntu

* `reindex_stable.sh` - Create a local APT repository on CentOS, useful
for releasing your own packages or packages you want to keep seperate
from the upstream release packages.

Based on:
http://troubleshootingrange.blogspot.com/2012/09/hosting-simple-apt-repository-on-centos.html

* `sync-ubuntu.sh` - Wrapper around `debmirror` to mirror only specific
releases from upstream. Kind of a mess and work in progress, but usable.
