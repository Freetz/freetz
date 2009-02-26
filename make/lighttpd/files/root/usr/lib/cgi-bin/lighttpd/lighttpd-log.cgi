#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

let _width=$_cgi_width-230

LOGA=$(cat /mod/etc/lighttpd/lighttpd.conf | grep "accesslog.filename" | cut -d\" -f 2)
LOGE=$(cat /mod/etc/lighttpd/lighttpd.conf | grep "server.errorlog" | cut -d\" -f 2)

if [ -f /usr/lib/mod_accesslog.so ]; then
	if [ -r "$LOGA" ]; then
        	echo "<h1>lighttpd access log $LOGA</h1>"
	        echo -n '<pre style="height: 480px width: '$_width'px; overflow: auto;">'
        	html < $LOGA
	        echo '</pre>'
	else
		echo "<h1>lighttpd access log $LOGA unavailable</h1>"
	fi
else
	echo "<h1>mod_accesslog unavailable</h1>"
fi

if [ -r "$LOGE" ]; then
        echo "<h1>lighttpd access log $LOGE</h1>"
        echo -n '<pre style="height: 480px width: '$_width'px; overflow: auto;">'
        html < $LOGE
        echo '</pre>'
else
	echo "<h1>lighttpd error log $LOGE unavailable</h1>"
fi

