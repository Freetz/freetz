#!/bin/sh


. /usr/lib/libmodcgi.sh

cgi --style=mod/mounted.css --id=status
cgi_begin "$(lang de:"Status" en:"Status")"

for part in ./status.d/*.sh; do
	[ -r "$part" ] && source "$part"
done

cgi_end
