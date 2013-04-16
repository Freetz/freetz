#!/bin/sh

. /usr/lib/libmodcgi.sh
. /mod/etc/conf/privoxy.cfg

echo "<h1>Privoxy logfile $(realpath $PRIVOXY_LOGDIR/$PRIVOXY_LOGFILE)</h1>"
if [ -f "$PRIVOXY_LOGDIR/$PRIVOXY_LOGFILE" ]; then
	echo -n '<pre class="log full">'
	html < "$PRIVOXY_LOGDIR/$PRIVOXY_LOGFILE"
	echo '</pre>'
else
	html "$(lang de:"Die Logdatei ist leer." en:"The logfile is empty.")"
fi
