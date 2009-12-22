#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

. /mod/etc/conf/syslogd.cfg

if [ "$SYSLOGD_LOCAL" = "yes" ]; then
	let _width=$_cgi_width-230
	if [ "$SYSLOGD_LOGGING" = "circular_buffer" ]; then
		echo '<h1>$(lang de:"Ringpuffer" en:"Memory buffer")</h1>'
		echo '<pre style="width: '$_width'px; overflow: auto; max-height: 550px;">'
		logread | html
		echo '</pre>'
	elif [ "$SYSLOGD_LOGGING" = "log_to_file" ]; then
		if [ -e "$SYSLOGD_ALTERNATIVE_LOGFILE" ]; then
			echo "<h1>$SYSLOGD_ALTERNATIVE_LOGFILE</h1>"
			echo '<pre style="width: '$_width'px; overflow: auto; max-height: 550px;">'
			html < "$SYSLOGD_ALTERNATIVE_LOGFILE"
			echo '</pre>'
		else
			if [ -e "/var/log/messages" ]; then
				echo '<h1>/var/log/messages</h1>'
				echo '<pre style="width: '$_width'px; overflow: auto; max-height: 550px;">'
				html < "/var/log/messages"
				echo '</pre>'
			fi
		fi
	fi
else
	echo '<h1>$(lang de:"Kein lokales Loggen aktiviert" en:"No local logging enabled")!</h1>'
fi

