#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

_cgi=$(cgi_param cgi | tr -d .)
pkg=${_cgi%%/*}
cgi=${_cgi#*/}

OIFS=$IFS; IFS='|'
set -- $(grep "^$pkg|.*|$cgi\$" /mod/etc/reg/status.reg)
IFS=$OIFS
title=$2

cgi_begin "$title" "status:$pkg/$cgi"

if [ -x "/mod/usr/lib/cgi-bin/$pkg/$cgi.cgi" ]; then
	. "/mod/usr/lib/cgi-bin/$pkg/$cgi.cgi"
else
	echo "<p><b>$(lang de:"Fehler" en:"Error"):</b> $(lang de:"Kein Skript f&uuml;r die Statusanzeige" en:"no script for status display") '$pkg/$cgi'.</p>"
fi

cgi_end
