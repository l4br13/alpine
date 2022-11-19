__reset__ () {
	printf "Are you sure want to reset [Y/n]? "
	read c
	if [ "$c" != "y" ]; then
		exit 1
	fi
	if [ ! -z $sudo ]; then
		sudo rm -rf $root/*
	else
		rm -rf $root/*
	fi
	return 1
}