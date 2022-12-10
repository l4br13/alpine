__reset__ () {
	printf "$(basename $0): reset\n"
	printf "Are you sure want to reset [Y/n]? "
	read c
	if [ "$c" != "y" ]; then
		printf "operation canceled by the user.\n"
		exit 1
	fi
	if [ ! -z $sudo ]; then
		sudo rm -rf $root/*
	else
		rm -rf $root/*
	fi
	printf "done.\n"
	return 1
}