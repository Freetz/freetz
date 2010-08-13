#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /mod/etc/conf/inotify-tools.cfg

echo "<h1>$INOTIFY_TOOLS_LOGFILE</h1>"
if [ -r "$INOTIFY_TOOLS_LOGFILE" ]; then
	let _width=$_cgi_width-230
	echo -n '<pre style="height: 480px; width: '$_width'px;">'
	html < "$INOTIFY_TOOLS_LOGFILE"
	echo '</pre>'
else
	html "$(lang de:"Die Logdatei ist leer." en:"Logfile is empty.")"
fi

