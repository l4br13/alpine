#!/bin/sh
this=$(dirname $(realpath $0))
arch=$(uname -m)
os=$(uname -o)
ver=$(curl -s http://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$arch/latest-releases.yaml | grep -m 1 -o version.* | sed -e 's/[^0-9.]*//g' -e 's/-$//')
if [ $os = "Android" ]; then
	if [ ! -e ${PREFIX}/bin/curl ]; then
		apt install -y curl || {
			exit 1
		}
	fi
	if [ ! -e ${PREFIX}/bin/proot ]; then
		apt install -y proot || {
			exit 1
		}
	fi
	if [ ! -e ${PREFIX}/bin/tar ]; then
		apt install -y tar || {
			exit 1
		}
	fi
fi
if [ -z "$ver" ]; then
	if [ ! -f latest-releases.yaml ]; then
		echo "internet connection is needed."
		exit 1
	else
		ver=$(cat latest-releases.yaml | grep -m 1 -o version.* | sed -e 's/[^0-9.]*//g' -e 's/-$//')
		rootfs="alpine-minirootfs-${ver}-${arch}.tar.gz"
		if [ ! -f $rootfs ]; then
			exit 1
		fi
		if [ ! -f "${rootfs}.sha256" ]; then
			exit 1
		fi
	fi
else
	curl --silent --fail --retry 4 -O http://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$arch/latest-releases.yaml
	ver=$(cat latest-releases.yaml | grep -m 1 -o version.* | sed -e 's/[^0-9.]*//g' -e 's/-$//')
	url="http://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$arch/alpine-minirootfs-${ver}-${arch}.tar.gz"
	rootfs="alpine-minirootfs-${ver}-${arch}.tar.gz"
	if [ ! -f $rootfs ]; then
		curl --progress-bar -L --fail --retry 4 -O $url
	fi
	if [ ! -f "${rootfs}.sha256" ]; then
		curl --progress-bar -L --fail --retry 4 -O "${url}.sha256"
	fi
fi
sha256sum -c --quiet ${rootfs}.sha256 || {
		printf "$rootfs : corrupted\n"
		exit 1
}
if [ $os = "GNU/Linux" ]; then
	tar -xf $rootfs
	echo '#!/bin/sh
if [ $(id -u) != 0 ]; then
	exit
fi
root=$(dirname $(realpath $0))
mount -t proc /proc $root/proc/
mount -t sysfs /sys $root/sys/
cp /etc/resolv.conf $root/etc/resolv.conf
chroot $root /bin/sh --login
umount -r $root/proc/
umount -r $root/sys/' > $this/init
	chmod 700 $this/init
	cp $this/etc/apk/repositories $this/etc/apk/repositories.bak
	cat > $this/etc/apk/repositories <<- EOM
	http://dl-cdn.alpinelinux.org/alpine/latest-stable/main/
	http://dl-cdn.alpinelinux.org/alpine/latest-stable/community/
	http://dl-cdn.alpinelinux.org/alpine/edge/testing/
	EOM
	printf "nameserver 8.8.8.8\nnameserver 8.8.4.4" > $this/etc/resolv.conf
elif [ $os = "Android" ]; then
	alpine="$(realpath $PREFIX/..)/alpine"
	if [ ! -d $alpine ]; then
		mkdir $alpine
	fi
	tar -xf $rootfs -C $alpine/
	cat > $alpine/init <<- EOM
#!/data/data/com.termux/files/usr/bin/bash -e
root=$(dirname $(realpath $0))
unset LD_PRELOAD
addresolvconf ()
{
  android=\$(getprop ro.build.version.release)
  if [ \${android%%.*} -lt 8 ]; then
  [ \$(command -v getprop) ] && getprop | sed -n -e 's/^\[net\.dns.\]: \[\(.*\)\]/\1/p' | sed '/^\s*$/d' | sed 's/^/nameserver /' > \${alpine}/etc/resolv.conf
  fi
}
addresolvconf
exec proot --link2symlink -0 -r ${alpine}/ -b /dev/ -b /sys/ -b /proc/ -b /sdcard -b /storage -b $HOME -w /home /usr/bin/env TMPDIR=/tmp HOME=/home PREFIX=/usr SHELL=/bin/sh TERM="$TERM" LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/sh --login
EOM
	chmod +x $alpine/init
	ln -sf $alpine/init $PREFIX/bin/startalpine
	cp $alpine/etc/apk/repositories $alpine/etc/apk/repositories.bak
	cat > $alpine/etc/apk/repositories <<- EOM
http://dl-cdn.alpinelinux.org/alpine/latest-stable/main/
http://dl-cdn.alpinelinux.org/alpine/latest-stable/community/
http://dl-cdn.alpinelinux.org/alpine/edge/testing/
EOM
	printf "nameserver 8.8.8.8\nnameserver 8.8.4.4" > $alpine/etc/resolv.conf
fi
