#!/bin/sh
os=$(uname -o)
if [ $os = "Android" ]; then
	rm -rf $PREFIX/../alpine
fi
