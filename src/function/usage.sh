__usage__ () {
	printf "Usage:	$(basename $0) [options] | [commands] <arguments>\n"
	printf "\n"
	printf "Options:\n"
	printf "	-d, --deploy <release>		deploy alpine rootfs to current dir.\n"
	printf "	-i, --install <release>		install alpine rootfs.\n"
	printf "	-r, --reset			reset alpine rootfs.\n"
	printf "	-l, --login			login to Alpine Linux rootfs.\n"
	printf "	-v, --version			show Alpine Linux version info.\n"
	printf "	-h, --help			show help information.\n"
	printf "\n"
	return 1
}
