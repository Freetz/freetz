#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin

cgi_width=560
. /usr/lib/libmodcgi.sh

eval "$(modcgi mac:interf wol)"

if [ -z "$WOL_MAC" ]; then
	cgi_begin '$(lang de:"Fehler" en:"Error")'
	echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Keine MAC Adresse angegeben" en:"no MAC address given")</p>"
	cgi_end
	exit 1
fi

cgi_begin '$(lang de:"Wecke '\"$WOL_MAC\"' auf..." en:"Wake up '\"$WOL_MAC\"'...")'

echo -n '<pre>sending magic frame...'

if [ -z "$WOL_INTERF" ]; then
	ether-wake "$WOL_MAC" 2>&1
else
	ether-wake -i "$WOL_INTERF" "$WOL_MAC" 2>&1
fi

echo 'done.</pre>'
echo '<form action="/cgi-bin/index.cgi"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form>'

cgi_end
