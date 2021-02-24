#!/bin/sh

. /usr/lib/libmodcgi.sh
. /mod/etc/conf/dehydrated.cfg

echo "<h1>Let's Encrypt logfile $(realpath $DEHYDRATED_LOGFILE)</h1>"
if [ -f "$DEHYDRATED_LOGFILE" ]; then
	echo -n '<pre class="log full">'
	html < "$DEHYDRATED_LOGFILE"
	echo '</pre>'
else
	html "$(lang de:"Die Logdatei ist leer." en:"The log file is empty.")"
fi

