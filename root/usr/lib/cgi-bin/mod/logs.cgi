
let _width=$_cgi_width-230

if [ -r /var/log/mod_load.log ]; then
	echo '<h1>/var/log/mod_load.log</h1>'
	echo -n '<pre style="width: '$_width'px; overflow: auto;">'
	html < /var/log/mod_load.log
	echo '</pre>'
fi

if [ -r /var/log/mod_net.log ]; then
	echo '<h1>/var/log/mod_net.log</h1>'
	echo -n '<pre style="width: '$_width'px; overflow: auto;">'
	html < /var/log/mod_net.log
	echo '</pre>'
fi

if [ -r /var/log/mod_voip.log ]; then
	echo '<h1>/var/log/mod_voip.log</h1>'
	echo -n '<pre style="width: '$_width'px; overflow: auto;">'
	html < /var/log/mod_voip.log
	echo '</pre>'
fi

if [ -r /var/log/mod.log ]; then
	echo '<h1>/var/log/mod.log</h1>'
	echo -n '<pre style="width: '$_width'px; overflow: auto;">'
	html < /var/log/mod.log
	echo '</pre>'
fi

