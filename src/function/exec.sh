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
			sudo cp /etc/resolv.conf $root/etc/resolv.conf
			sudo chroot $root sh -c "$*" || {
				sudo umount -rq $root/proc/
				sudo umount -rq $root/sys/
				sudo umount --recursive $root/dev/
				PATH=$OLD_PATH
				exit
			}
			sudo umount -rq $root/proc/
			sudo umount -rq $root/sys/
			sudo umount --recursive $root/dev/
			PATH=$OLD_PATH
			exit
		else 
			old_path=$PATH
			root=$dir/rootfs
			PATH=$old_path:/bin
			mount -t proc /proc $root/proc/
			mount -t sysfs /sys $root/sys/
			mount -o bind /dev $root/dev/
			cp /etc/resolv.conf $root/etc/resolv.conf
			chroot $root /bin/sh -c "$*" || {
				umount -rq $root/proc/
				umount -rq $root/sys/
				umount --recursive $root/dev/
				PATH=$old_path
				exit
			}
			umount -rq $root/proc/
			umount -rq $root/sys/
			umount --recursive $root/dev/
			PATH=$old_path
			exit
		fi
	fi
	return 1
}
