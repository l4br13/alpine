#!/bin/sh
this=$(dirname $(realpath $0))
arch=$(uname -m)
os=$(uname -o)
ver=$(curl -s http://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$arch/latest-releases.yaml | grep -m 1 -o version.* | sed -e 's/[^0-9.]*//g' -e 's/-$//')
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
tar -xf $rootfs
if [ "$os" == "GNU/Linux" ]; then
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
umount -l $root/proc/
umount -l $root/sys/' > $this/init
	chmod 700 $this/init
elif [ "$os" == "Android" ]; then
	echo ${PREFIX}
fi