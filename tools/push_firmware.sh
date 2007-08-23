#!/bin/bash

# push_firmware.sh
#
# Flash kernel image (contiguous hidden root) to Fritz!Box or Speedport.
# Works on Linux (main platform) and Cygwin (inofficially).
#
# Copyright (c) 2007 Michael Hampicke    (mike@mhampicke.de)
#               2007 Alexander Kriegisch (kriegaex, ip-phone-forum.de)
#
# Cygwin users note:
#   1. There is NO guarantee whatsoever that this will work on Cygwin, even
#      though it does on my box (kriegaex). Provided as is.
#   2. For FTP you need the 'ncftp' cygwin package (category 'net').
#   3. You need the 'ping' command from Windows (tested on XP), NOT from the
#      'ping' cygwin package (please uninstall or change path so Windows
#      version is found first), because the cygwin version has no timeout
#      parameter as of today (2007-07-11).
#   4. For 'hexdump' you need the 'util-linux' cygwin package (category
#      'utils').
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
	echo " * You should now reboot your box."
	echo "   Waiting for box to shut down."
	echo "   Tip: switch off, if reboot is not detected because it happens too quickly"
	echo -n "   "
	while eval "ping $ping_params $ip > /dev/null"; do
		echo -n "."
		sleep 0.2
	done
	echo

	echo
	echo " * No reply from box. Assuming switch-off or restart."
	echo "   Trying to re-detect box."
	echo -n "   "
	while ! eval "ping $ping_params $ip > /dev/null"; do
		echo -n "."
		sleep 0.2
	done
	echo

	echo
	echo " * Box is back up again."
	echo "   Initiating transfer."
	echo "   Tip: switch off/on box several times, if FTP client cannot log in ..."
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

	echo
	echo "Script has been written for ds26, cannot use for ds24 as-is"
	echo "TODO: FIXME"
	echo
	exit 1

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

img=""
hexdump -n4 "$1" | grep -iq "1281 feed" && img="$1"
if [ -z "$img" ]; then
	echo >&2
	echo "Error: file is not a valid image to be written to mtd1. Please use a" >&2
	echo "hidden root 'kernel.image' containing both Linux kernel and file system." >&2
	if tar tf "$1" ./var/tmp/kernel.image > /dev/null 2>&1; then
		echo >&2
		echo "Hint: file seems to be a full firmware image archive in 'tar' format" >&2
		echo "containing the 'kernel.image' you are looking for. Please extract the archive" >&2
		echo "by means of 'tar xf', then call this script again upon the extracted " >&2
		echo "'kernel.image'." >&2
	fi
	echo >&2
	exit 1
fi

ping_params="-c1 -w1"
if [ "$(uname -o)" == "Cygwin" ]; then
	CYGWIN=1
	ping_params="-n 1 -w 500"
fi

if [ "$2" = "-f" ]; then
	push_fw "$img" "$3"
else
	echo
	echo		"!!! WARNING !!! WARNING !!! WARNING !!! WARNING !!! WARNING !!!" 
	echo		"!!!   THERE IS NO WARRENTY AT ALL !!! USE AT YOU OWN RISK   !!!"
	echo
	echo	-n	"Are you sure, that you want to flash "
	echo	-en	"\033[4m$img\033[0m "
	echo	-n	"directly to "
	echo	-e	"\033[4mmtd1\033[0m?"
	echo
	echo	-n	"proceed (y/n) "

	read -n 1 -s PROCEED
	echo

	if [ "$PROCEED" = "y" ]; then
		push_fw "$img" "$2"
	else
		echo
		echo "aborted"
	fi
fi
