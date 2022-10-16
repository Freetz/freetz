#!/bin/sh

. /usr/lib/libmodcgi.sh
. /mod/etc/conf/httpry.cfg

echo "<h1>$HTTPRY_LOGFILE</h1>"
if [ -f "$HTTPRY_LOGFILE" ]; then
	echo -n '<pre class="log full">'
	html < "$HTTPRY_LOGFILE"
	echo '</pre>'
else
	html "$(lang de:"Die Logdatei ist leer." en:"The logfile is empty.")"
fi

