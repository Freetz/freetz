#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /mod/etc/conf/inotify-tools.cfg

echo "<h1>$INOTIFY_TOOLS_LOGFILE</h1>"
if [ -r "$INOTIFY_TOOLS_LOGFILE" ]; then
	echo -n '<pre class="log">'
	html < "$INOTIFY_TOOLS_LOGFILE"
	echo '</pre>'
else
	html "$(lang de:"Die Logdatei ist leer." en:"Logfile is empty.")"
fi

