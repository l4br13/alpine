# Name
alpine - linux mini rootfs wrapper script


# Synopsis
```bash
$ alpine [command or options]
```

see more with
```bash
$ alpine --help
```

# Installation
run the install file as root

for android in Termux app just do it without root previlege
``` bash
./install
```

after you do the installation.
it will place alpine to /usr/bin/alpine

if you want to remove, just remove the file on /usr/bin/alpine
and do not forget to delete /var/lib/alpine if you want to delete the data too.

in android termux , the path is on usr dir you can do
``` bash
cd $PREFIX
```
to go the root and find the alpine files


# Notes

never run alpine as root, for the security reason

alpine will store data to directory '/var/lib/alpine'
the rootfs will be placed on '/var/lib/alpine/rootfs'
