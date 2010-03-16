#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi=$(cgi_param cgi | tr -d .)

OIFS=$IFS; IFS='|'
set -- $(grep "|$cgi\$" /mod/etc/reg/status.reg)
IFS=$OIFS
package=$1

cgi_begin "$package" "status_$cgi"

if [ -x "/mod/usr/lib/cgi-bin/$cgi.cgi" ]; then
	. "/mod/usr/lib/cgi-bin/$cgi.cgi"
else
	echo "<p><b>$(lang de:"Fehler" en:"Error"):</b> $(lang de:"Kein Skript f&uuml;r die Statusanzeige" en:"no script for status display") '$cgi'.</p>"
fi

cgi_end
