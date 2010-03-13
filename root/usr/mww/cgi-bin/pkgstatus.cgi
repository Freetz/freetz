#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

package=$(cgi_param pkg)
cgi=$(cgi_param cgi | tr -d .)

cgi_begin "$package" "status_$cgi"


if [ -x "/mod/usr/lib/cgi-bin/$cgi.cgi" ]; then
	. /mod/usr/lib/cgi-bin/$cgi.cgi
else
	echo "<p><b>$(lang de:"Fehler" en:"Error"):</b> $(lang de:"Kein Skript f&uuml;r das die Statusanzeige" en:"no script for status display") '$package/$cgi'.</p>"
fi

cgi_end
