#!/bin/sh
#
# Copyright (c) 2007 Michael Hampicke <mike@mhampicke.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

function push() {
	echo
	echo " * You should now reboot your box. Waiting for box to shut down for restart ..."
	while [ `ping -c1 -w1 192.168.178.1 | grep 'receive' | awk '{ print $4 }'` == "1" ]; do
		sleep 1
	done

	echo
	echo " * No reply from box. Assuming restart ..."
	while [ `ping -c1 -w1 192.168.178.1 | grep 'receive' | awk '{ print $4 }'` == "0" ]; do
		sleep 1
	done

	echo
	echo " * Box is back up again. Initiating transfer of '$1' ..."
	echo

	ftp -n -p <<'EOT'
open 192.168.178.1
user adam2 adam2
debug
bin
quote MEDIA FLSH
put $1 mtd1
quote REBOOT
quit
EOT
	return 0
}

###

if [ -z "$1" ]; then
	echo
	echo "Usage: $0 <firmware> [ -f ]"
	echo ""
	echo "firmware    firmware file to flash (mostly kernel.image)"
	echo "-f          disable safty prompt"
	echo
	exit 1
fi

if [ "$2" = "-f" ]; then
	push $1
else
	echo
	echo		"!!! WARNING !!! WARNING !!! WARNING !!! WARNING !!! WARNING !!!" 
	echo		"!!!   THERE IS NO WARRENTY AT ALL !!! USE AT YOU OWN RISK   !!!"
	echo
	echo	-n	"Are you sure, that you want to flash "
	echo	-en	"\033[4m$1\033[0m "
	echo	-n	"directly to "
	echo	-e	"\033[4mmtd1\033[0m?"
	echo
	echo	-n	"proceed (y/n) "

	read -n 1 -s PROCEED
	echo

	if [ "$PROCEED" = "y" ]; then
		push $1	
	else
		echo
		echo "aborted"
	fi
fi
