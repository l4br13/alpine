if [ ! -z $com ]; then
	if [ ! -f $root/etc/os-release ]; then
		printf "$(basename $0): is not installed.\n"
		printf "Try 'alpine --install' to install.\n"
		exit 1
	fi
	__exec__ $__com__
else
	if [ ! -z $__help__ ]; then
		__usage__
	fi

	if [ ! -z $__version__ ]; then
		__version__
	fi

	if [ ! -z $__deploy__ ]; then
		__deploy__
	fi

	if [ ! -z $__reset__ ]; then
		__reset__
	fi

	if [ ! -z $__install__ ]; then
		__install__
	fi

	if [ ! -z $__update__ ]; then
		__update__
	fi

	if [ ! -z $__login__ ]; then
		__login__
	fi
fi
