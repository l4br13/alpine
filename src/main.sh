if [ ! -z $__help__ ]; then
	__usage__
elif [ ! -z $__version__ ]; then
	if [ -f $root/etc/os-release ]; then
		__version__
	else
		exit 1
	fi
elif [ ! -z $__reset__ ]; then
	__reset__
elif [ ! -z $__install__ ]; then
	__install__
elif [ ! -z $__login__ ]; then
	__login__
elif [ ! -z $__update__ ]; then
	__update__
else
	if [ ! -f $root/etc/os-release ]; then
		printf "$(basename $0): is not installed.\n"
		printf "Try 'alpine --install' to install.\n"
		exit 1
	fi
	__exec__ $__com__
fi