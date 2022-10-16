#!/bin/sh


. /usr/lib/libmodcgi.sh


for logfile in access cache store; do
	LOGLINK=/var/log/squid_${logfile}.log

	echo "<h1>$LOGLINK ($(html "$(ls -al $LOGLINK | sed 's/.* -> //g')"))</h1>"
	if [ -r "$LOGLINK" ]; then
		echo -n '<pre class="log full">'
		html < "$LOGLINK"
		echo '</pre>'
	else
		html "$(lang de:"Diese Logdatei ist leer." en:"This logfile is empty.")"
	fi

done

