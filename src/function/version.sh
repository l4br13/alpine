__version__ () {
	if [ ! -f $root/etc/os-release ]; then
		exit 1
	fi
	. $root/etc/os-release
	printf "$PRETTY_NAME\n"
	return 1
}