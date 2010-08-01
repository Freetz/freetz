#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

EXTRA_REG=/mod/etc/reg/extra.reg

[ -e "$EXTRA_REG" ] || touch "$EXTRA_REG"

if [ -z "$PATH_INFO" ]; then
    	source extra_list.sh
	exit
fi

path_info pkg cgi remaining_path
if ! valid package "$pkg" || ! valid id "$cgi"; then
	cgi_error "Invalid path"
fi
IFS='|'
set -- $(grep "^$pkg|.*|$cgi\$" "$EXTRA_REG")
IFS=$OIFS

if [ "$sec_level" -gt "$3" ]; then
	cgi_begin 'Extras'
	echo '<h1>$(lang de:"Zusatz-Skript" en:"Additional script")</h1>'
	echo '<div style="color: #800000;">$(lang
		de:"Dieses Zusatz-Skript in der aktuellen Sicherheitsstufe
		    nicht verf&uuml;gbar!" 
		en:"This script is not available at the current security
		    level!"
		)</div>'
	echo '<p>'
	back_button --title="$(lang de:"Zu den Extras" en:"Goto extras")" mod extras
	cgi_end
	exit
fi

path="$pkg/$cgi"
script="/mod/usr/lib/cgi-bin/$path.cgi"
if [ -x "$script" ]; then
	export PATH_INFO=$remaining_path
	export SCRIPT_NAME="$SCRIPT_NAME/$path"
	"$script"
else
	cgi_error "$(lang 
		de:"Zusatz-Skript '$path.cgi' nicht gefunden."
		en:"Additional script '$path.cgi' not found."
	)"
fi
