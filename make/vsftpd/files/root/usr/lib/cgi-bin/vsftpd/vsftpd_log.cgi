#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

echo "<h1>/var/log/mod_vsftpd.log ($(ls -al /var/log/mod_vsftpd.log|sed 's/.* -> //g'))</h1>"
if [ -r "/var/log/mod_vsftpd.log" ]; then
	echo -n '<pre style="height: 480px; width: 500px; overflow: auto;">'
	httpd -e "$(cat /var/log/mod_vsftpd.log)"
	echo '</pre>'
else
	httpd -e "$(lang de:"Die Logdatei ist leer." en:"Logfile is empty.")"
fi

