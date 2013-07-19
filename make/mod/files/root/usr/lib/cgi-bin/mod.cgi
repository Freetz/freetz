#!/bin/sh


. /usr/lib/libmodcgi.sh

inetd=false
[ -e /mod/etc/default.inetd/inetd.cfg ] && inetd=true

CONF=/usr/lib/cgi-bin/mod/conf
for conf in "$CONF"/*.sh; do
	[ -r "$conf" ] && source "$conf"
done
