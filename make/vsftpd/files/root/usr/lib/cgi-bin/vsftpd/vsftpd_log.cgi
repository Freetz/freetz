#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

LOGLINK=/var/log/mod_vsftpd.log

echo "<h1>$LOGLINK ($(html "$(ls -al /var/log/mod_vsftpd.log|sed 's/.* -> //g')"))</h1>"
if [ -r "$LOGLINK" ]; then
	let _width=$_cgi_width-230
	echo -n '<pre style="height: 480px; width: '$_width'px; overflow: auto;">'
	html < "$LOGLINK"
	echo '</pre>'
else
	html "$(lang de:"Die Logdatei ist leer." en:"Logfile is empty.")"
fi

