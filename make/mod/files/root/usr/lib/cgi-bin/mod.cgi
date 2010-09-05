#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

inetd=false
[ -e /etc/default.inetd/inetd.cfg ] && inetd=true

CONF=/usr/lib/cgi-bin/mod/conf
for conf in "$CONF"/*.sh; do
	[ -r "$conf" ] && source "$conf"
done
