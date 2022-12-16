case $1 in
	-*)
		break
	;;
	*)
		com=1
		__com__=$@
		break
	;;
esac

if [ -z $com ]; then
	opt=$(getopt -n $(basename $0) -o hvdrilu -l help,version,deploy,reset,install,login,update -- "$@")
	if [ $? -ne 0 ]; then
		printf "Try '$(basename $0) --help' for more information.\n"
		exit
	fi
	eval set -- $opt
	while true; do
		if [ "$1" = "--" ]; then
			shift
			__param__=$@
			break
		else
			case $1 in
				--help|-h)
					__help__=1
				;;
				--version|-v)
					__version__=1
				;;
				--deploy|-d)
					__deploy__=1
				;;
				--reset|-r)
					__reset__=1
				;;
				--install|-i)
					__install__=1
				;;
				--login|-l)
					__login__=1
				;;
				--update|-u)
					__update__=1
				;;
				*)
					break
				;;
			esac
		fi
		shift
	done
fi