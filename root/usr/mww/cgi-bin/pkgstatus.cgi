#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

path_info pkg cgi remaining_path
if ! valid package "$pkg" || ! valid id "$cgi"; then
	cgi_error "Invalid path"
	exit 1
fi

OIFS=$IFS; IFS='|'
set -- $(grep "^$pkg|.*|$cgi\$" /mod/etc/reg/status.reg)
IFS=$OIFS

title=$2

# FIXME: Attach meta-data to mounted.cgi
cgi --style=mod/mounted.css --style=mod/freetz-conf.css
cgi --id="status:$pkg/$cgi"
cgi_begin "$title"

if [ -n "$1" -a -x "/mod/usr/lib/cgi-bin/$pkg/$cgi.cgi" ]; then
    	SCRIPT_NAME="$SCRIPT_NAME/$pkg/$cgi"
	PATH_INFO=$remaining_path
	. "/mod/usr/lib/cgi-bin/$pkg/$cgi.cgi"
else
	print_error "$(lang de:"Kein Skript f&uuml;r die Statusanzeige" en:"no script for status display") '$pkg/$cgi'."
fi

cgi_end
