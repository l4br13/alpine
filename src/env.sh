program=$(basename $0)
program_version="1.1.0"
os=$(uname -o)

if [ $os = "Android" ]; then
	dir=$PREFIX/var/lib/alpine
	tmp=$PREFIX/tmp/alpine
	root=$dir/rootfs
	[ -d $tmp ] || mkdir $tmp
else
	dir=/var/lib/alpine
	tmp=/tmp/alpine
	root=$dir/rootfs
	[ -d $tmp ] || mkdir $tmp
	if [ $(id -u) != 0 ]; then
		[ ! -f $prefix/bin/sudo ] || sudo=1
	fi
fi