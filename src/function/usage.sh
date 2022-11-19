__usage__ () {
	printf "Usage:	$(basename $0) [options] | [commands] <arguments>\n"
	printf "\n"
	printf "Options:\n"
	printf "	--install <releases>	install alpine rootfs.\n"
	printf "	--reset			reset alpine rootfs.\n"
	printf "	--login			login to Alpine Linux rootfs.\n"
	printf " -v,	--version		show Alpine Linux version info.\n"
	printf " -h,	--help			show help information.\n"
	printf "\n"
	return 1
}