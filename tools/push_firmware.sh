#!/bin/sh

# push_firmware.sh
#
# Flash kernel image (contiguous hidden root) to Fritz!Box or Speedport.
# Works on Linux and Cygwin, but the latter needs ncftpput from ncftp package.
#
# Copyright (c) 2007 Michael Hampicke    (mike@mhampicke.de)
#               2007 Alexander Kriegisch (kriegaex, ip-phone-forum.de)
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

function push_fw() {
	trap 'echo ; echo "aborted" ; exit 1' TERM INT

	local ip=192.168.178.1
	[ -n "$2" ] && ip="$2"

	echo
	echo    " * You should now reboot your box now."
	echo
	echo -n " * Waiting for box "
	while ! ping -c1 -w1 $ip > /dev/null ; do
		echo -n "."
		true
	done
	echo

	echo
	echo " * Box is back up again."
	echo "   Initiating transfer - switch box off/on several times, if FTP Client cannot log in ..."

	echo
	if [ $CYGWIN ]; then
		ncftpput \
			-d stdout \
			-o doNotGetStartCWD=1,useFEAT=0,useHELP_SITE=0,useCLNT=0,useSIZE=0,useMDTM=0 \
			-W "quote MEDIA FLSH" \
			-Y "quote REBOOT" \
			-u adam2 -p adam2 \
			-C $ip \
			$1 mtd1
	else
		ftp -n -p <<EOT
open $ip
user adam2 adam2
debug
bin
quote MEDIA FLSH
put $1 mtd1
quote REBOOT
quit
EOT
	fi
	return 0
}

if [ -z "$1" ]; then
	echo
	echo "Usage: $0 <firmware> [ -f ] [ <ip> ]"
	echo ""
	echo "firmware    firmware file to flash (mostly kernel.image)"
	echo "-f          disable safety prompt"
	echo "ip          bootloader IP address (default: 192.168.178.1)"
	echo
	exit 1
fi

[ "$(uname -o)" == "Cygwin" ] && CYGWIN=1

if [ "$2" = "-f" ]; then
	push_fw "$1" "$3"
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
		push_fw "$1" "$2"
	else
		echo
		echo "aborted"
	fi
fi
