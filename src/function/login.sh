__login__ () {
	if [ ! -f $root/etc/os-release ]; then
		printf "$(basename $0): is not installed.\n"
		printf "Try 'alpine --install' to install.\n"
		exit 1
	fi
	__exec__ "sh --login"
}