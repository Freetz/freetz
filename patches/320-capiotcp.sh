#!/bin/bash

rm_files()
{
	for file in $1; do
		echo2 "$file"
		rm -rf "$file"
	done
}

if [ "$DS_REMOVE_CAPIOVERTCP" == "y" ]; then
	echo1 "removing capiotcp_server"
	rm_files /usr/bin/capiotcp_server
fi
