#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

echo "<h1>/var/log/mod_vsftpd.log ($(ls -al /var/log/mod_vsftpd.log|sed 's/.* -> //g'))</h1>"
if [ -r "/var/log/mod_vsftpd.log" ]; then
	let _width=$_cgi_width-230
	echo -n '<pre style="height: 480px; width: '$_width'px; overflow: auto;">'
	html < /var/log/mod_vsftpd.log
	echo '</pre>'
else
	html "$(lang de:"Die Logdatei ist leer." en:"Logfile is empty.")"
fi

