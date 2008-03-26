#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

package="$(echo "$QUERY_STRING" | sed -e 's/^.*pkg=//' -e 's/&.*$//' -e 's/\.//g')"
cgi="$(echo "$QUERY_STRING" | sed -e 's/^.*cgi=//' -e 's/&.*$//' -e 's/\.//g')"


cgi_begin "$package" "status_$(echo $cgi | sed -e "s/\//__/")"


if [ -x "/mod/usr/lib/cgi-bin/$cgi.cgi" ]; then
	/mod/usr/lib/cgi-bin/$cgi.cgi
else
	echo "<p><b>$(lang de:"Fehler" en:"Error"):</b> $(lang de:"Kein Skript f&uuml;r das die Statusanzeige" en:"no script for status display") '$package/$cgi'.</p>"
fi

cgi_end
