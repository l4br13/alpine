if [ $(id -u) = 0 ]; then
	printf "$(basename $0): does not run as root.\n"
	exit 1
fi