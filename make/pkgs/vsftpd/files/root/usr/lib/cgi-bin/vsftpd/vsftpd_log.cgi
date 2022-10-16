#!/bin/sh


. /usr/lib/libmodcgi.sh

LOGLINK=/var/log/vsftpd.log

echo "<h1>$LOGLINK ($(html "$(ls -al /var/log/vsftpd.log | sed 's/.* -> //g')"))</h1>"
if [ -r "$LOGLINK" ]; then
	echo -n '<pre class="log full">'
	html < "$LOGLINK"
	echo '</pre>'
else
	html "$(lang de:"Die Logdatei ist leer." en:"Logfile is empty.")"
fi

