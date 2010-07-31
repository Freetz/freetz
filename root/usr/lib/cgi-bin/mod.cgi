#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

inetd=false
[ -e /etc/default.inetd/inetd.cfg ] && inetd=true

CONF=/usr/lib/cgi-bin/mod/conf
conf() {
    	source "$CONF/$1.sh"
}
conf cron
conf swap
conf telnet
conf multid
conf webcfg
conf mount
conf external
