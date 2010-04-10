#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin

DAEMON=onlinechanged-cgi

if [ -f /tmp/flash/$DAEMON ]; then
case $1 in
	online )
		(sleep 5; sh /tmp/flash/$DAEMON online)&
	;;
	offline )
		(sleep 5; sh /tmp/flash/$DAEMON offline)&
	;;
esac
fi
