#!/bin/sh
this=$(dirname $(realpath $0))
os=$(uname -o)
if [ "$os" == "Android" ]; then
	rm -rf $PREFIX/../alpine
elif [ "$os" == "GNU/Linux" ]; then
	rm -rf $this/rootfs
	rm -rf $this/init
fi
