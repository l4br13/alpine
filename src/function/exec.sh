__exec__() {
	if [ $os = "Android" ]; then
		root=$dir/rootfs
		unset LD_PRELOAD
		android=$(getprop ro.build.version.release)
		if [ ${android%%.*} -lt 8 ]; then
			[ $(command -v getprop) ] && getprop | sed -n -e 's/^\[net\.dns.\]: \[\(.*\)\]/\1/p' | sed '/^\s*$/d' | sed 's/^/nameserver /' > $root/etc/resolv.conf
		fi
		exec proot --link2symlink -0 -r $root/ -b /dev/ -b /sys/ -b /proc/ -b /sdcard -b /storage -b $HOME -w /home /usr/bin/env TMPDIR=/tmp HOME=/root PREFIX=/usr SHELL=/bin/sh TERM="$TERM" LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin sh -c "$*"
		return 1
	else
		if [ ! -z $sudo ]; then
			root=$dir/rootfs
			OLD_PATH=$PATH
			PATH=$OLD_PATH:/bin:/sbin:/usr/bin
			sudo mount -t proc /proc $root/proc/
			sudo mount -t sysfs /sys $root/sys/
			sudo mount -o bind /dev $root/dev/
			sudo mount -o bind /run $root/run/
			sudo cp /etc/resolv.conf $root/etc/resolv.conf
			sudo chroot $root sh -c "$*" || {
				sudo umount --recursive $root/proc/
				sudo umount --recursive $root/sys/
				sudo umount --recursive $root/dev/
				sudo umount --recursive $root/run/
				PATH=$OLD_PATH
				exit
			}
			sudo umount --recursive $root/proc/
			sudo umount --recursive $root/sys/
			sudo umount --recursive $root/dev/
			sudo umount --recursive $root/run/
			PATH=$OLD_PATH
			exit
		else 
			old_path=$PATH
			root=$dir/rootfs
			PATH=$old_path:/bin
			mount -t proc /proc $root/proc/
			mount -t sysfs /sys $root/sys/
			mount -o bind /dev $root/dev/
			mount -o bind /run $root/run/
			cp /etc/resolv.conf $root/etc/resolv.conf
			chroot $root /bin/sh -c "$*" || {
				umount --recursive $root/proc/
				umount --recursive $root/sys/
				umount --recursive $root/dev/
				umount --recursive $root/run/
				PATH=$old_path
				exit
			}
			umount --recursive $root/proc/
			umount --recursive $root/sys/
			umount --recursive $root/dev/
			umount --recursive $root/run
			PATH=$old_path
			exit
		fi
	fi
	return 1
}

