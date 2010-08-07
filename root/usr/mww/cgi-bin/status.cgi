#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --style=mod/mounted.css
cgi_begin '$(lang de:"Status" en:"Status")' 'status'

for part in ./status.d/*.sh; do
	[ -r "$part" ] && source "$part"
done

cgi_end
