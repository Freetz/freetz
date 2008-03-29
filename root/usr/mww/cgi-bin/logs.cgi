#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

let _width=$_cgi_width-230
cgi_begin 'Logs' 'status_logs'

if [ -r "/var/log/mod_load.log" ]; then
	echo '<h1>/var/log/mod_load.log</h1>'
	echo -n '<pre style="width: '$_width'px; overflow: auto;">'
	httpd -e "$(cat /var/log/mod_load.log)"
	echo '</pre>'
fi

if [ -r "/var/log/mod_net.log" ]; then
	echo '<h1>/var/log/mod_net.log</h1>'
	echo -n '<pre style="width: '$_width'px; overflow: auto;">'
	httpd -e "$(cat /var/log/mod_net.log)"
	echo '</pre>'
fi

if [ -r "/var/log/mod_voip.log" ]; then
	echo '<h1>/var/log/mod_voip.log</h1>'
	echo -n '<pre style="width: '$_width'px; overflow: auto;">'
	httpd -e "$(cat /var/log/mod_voip.log)"
	echo '</pre>'
fi

if [ -r "/var/log/mod.log" ]; then
	echo '<h1>/var/log/mod.log</h1>'
	echo -n '<pre style="width: '$_width'px; overflow: auto;">'
	httpd -e "$(cat /var/log/mod.log)"
	echo '</pre>'
fi

cgi_end
