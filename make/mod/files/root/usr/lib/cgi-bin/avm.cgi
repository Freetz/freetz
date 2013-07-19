#!/bin/sh


. /usr/lib/libmodcgi.sh

inetd=false
[ -e /mod/etc/default.inetd/inetd.cfg ] && inetd=true

CONF=/usr/lib/cgi-bin/conf.avm
for conf in "$CONF"/*.sh; do
	[ -r "$conf" ] && source "$conf"
done
