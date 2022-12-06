__install__ () {
	if [ $os = "GNU/Linux" ]; then
		[ -z $sudo ] || {
			sudo -v || {
				printf "$(basename $0): permission denied\n"
				exit 1
			}
		}
	fi
	arch=$(uname -m)
	url=https://dl-cdn.alpinelinux.org
	mirror_url=$url/alpine/MIRRORS.txt
	mirrors=$(curl -s $mirror_url --connect-timeout 10 || {
		if [ -f $dir/MIRRORS.txt ]; then
			cat $dir/MIRRORS.txt
		fi
	})
	rel=latest-stable
	if [ ! -z $__param__ ]; then
		if [ "$__param__" = "edge" ]; then
			rel=edge
		elif [ "$__param__" = "stable" ]; then
			rel=latest-stable
		else
			rel=$__param__
		fi
	fi

	rel_url=$url/alpine/$rel/releases/$arch/latest-releases.yaml

	if [ ! -d $dir ]; then
		if [ ! -z $sudo ]; then
			sudo mkdir $dir
		else
			mkdir $dir
		fi
	fi

	if [ ! -d $root ]; then
		if [ ! -z $sudo ]; then
			sudo mkdir $root
		else
			mkdir $root
		fi
	fi
	
	if [ ! -z $sudo ]; then
		latest_releases=$(sudo curl -fs $rel_url -o $dir/$rel-releases.yaml --connect-timeout 10)
		if [ -f $dir/$rel-releases.yaml ]; then
			version=$(cat $dir/$rel-releases.yaml | grep -m 1 -o version.* | sed -e 's/[^0-9.]*//g' -e 's/-$//')
			rootfs="alpine-minirootfs-${version}-${arch}.tar.gz"
			url_rootfs=$url/alpine/$rel/releases/$arch/$rootfs
			rootfs_file=$dir/$rootfs
			if [ ! -f $dir/$rootfs ]; then
				sudo curl --progress-bar -L --fail --retry 4 $url_rootfs -o $rootfs_file || {
					printf "installation aborted.\n"
					exit 1
				}
			fi
			sudo tar -xf $rootfs_file -C $root || {
				printf "extract: error: $rootfs corrupted."
				rm -rf $rootfs_file
				printf "installation aborted.\n"
				exit 1
			}
			sudo cp $root/etc/apk/repositories $root/etc/apk/repositories.bak
			sudo rm -rf $tmp/repositories
			printf "https://dl-cdn.alpinelinux.org/alpine/$rel/main/\n" > $tmp/repositories
			printf "https://dl-cdn.alpinelinux.org/alpine/$rel/community/\n" >> $tmp/repositories
			if [ $rel = "edge" ]; then
				printf "https://dl-cdn.alpinelinux.org/alpine/edge/testing/\n" >> $tmp/repositories
			fi
			sudo cp $tmp/repositories $root/etc/apk/repositories
			sudo rm -rf $tmp/resolv
			printf "nameserver 1.1.1.1" > $tmp/resolv 
			sudo cp $tmp/resolv $root/etc/resolv.conf
			sudo rm -rf $tmp/profile
			cat $root/etc/profile > $tmp/profile
			echo "PS1='\W \\$ '" >> $tmp/profile
			echo 'cd $HOME' >> $tmp/profile
			sudo cp $tmp/profile $root/etc/profile
		fi
	else
		latest_releases=$(curl -s $rel_url -o $dir/$rel-releases.yaml --connect-timeout 10)
		if [ -f $dir/$rel-releases.yaml ]; then
			version=$(cat $dir/$rel-releases.yaml | grep -m 1 -o version.* | sed -e 's/[^0-9.]*//g' -e 's/-$//')
			rootfs="alpine-minirootfs-${version}-${arch}.tar.gz"
			url_rootfs=$url/alpine/$rel/releases/$arch/$rootfs
			rootfs_file=$dir/$rootfs
			if [ ! -f $dir/$rootfs ]; then
				curl --progress-bar -L --fail --retry 4 $url_rootfs -o $rootfs_file || {
					printf "installation aborted.\n"
					exit 1
				}
			fi
			tar -xf $rootfs_file -C $root || {
				printf "extract: error: $rootfs corrupted."
				rm -rf $rootfs_file
				printf "installation aborted.\n"
				exit 1
			}
			cp $root/etc/apk/repositories $root/etc/apk/repositories.bak
			rm -rf $tmp/repositories
			printf "https://dl-cdn.alpinelinux.org/alpine/$rel/main/\n" > $tmp/repositories
			printf "https://dl-cdn.alpinelinux.org/alpine/$rel/community/\n" >> $tmp/repositories
			if [ $rel = "edge" ]; then
				printf "https://dl-cdn.alpinelinux.org/alpine/edge/testing/\n" >> $tmp/repositories
			fi
			cp $tmp/repositories $root/etc/apk/repositories
			rm -rf $tmp/resolv
			printf "nameserver 1.1.1.1" > $tmp/resolv 
			cp $tmp/resolv $root/etc/resolv.conf
			rm -rf $tmp/profile
			cat $root/etc/profile > $tmp/profile
			echo "PS1='\W \\$ '" >> $tmp/profile
			echo 'cd $HOME' >> $tmp/profile
			cp $tmp/profile $root/etc/profile
		fi
	fi
	if [ -f $root/etc/os-release ]; then
		__update__
	fi
	return 1
}
