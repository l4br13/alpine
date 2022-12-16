__deploy__ () {
	if [ $os = "GNU/Linux" ]; then
		[ -z $sudo ] || {
			user=$USER
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
	rel=edge
	rel_url=$url/alpine/$rel/releases/$arch/latest-releases.yaml
	root=$(realpath $PWD)
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
			printf "$(basename $0): deploy: $root\n"
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
			sudo chown $user --recursive $root
		else
			if [ -z $latest_releases ]; then
				printf "$(basename $0): install error: internet connection required.\n"
				exit 1
			fi
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

			chown $user --recursive $root
		else
			if [ -z $latest_releases ]; then
				printf "$(basename $0): install error: internet connection required.\n"
				exit 1
			fi
		fi
	fi
	exit 0
}
