#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

. /mod/etc/conf/syslogd.cfg

log_stream() {
    	local title=$1
	echo "<h1>$title</h1>"
	echo '<pre style="max-height: 550px;">'
	html
	echo '</pre>'
}
log_file() {
	log_stream "$1" < "$1"
}

if [ "$SYSLOGD_LOCAL" = "yes" ]; then
	if [ "$SYSLOGD_LOGGING" = "circular_buffer" ]; then
		logread | log_stream '$(lang de:"Ringpuffer" en:"Memory buffer")'
	elif [ "$SYSLOGD_LOGGING" = "log_to_file" ]; then
		if [ -e "$SYSLOGD_ALTERNATIVE_LOGFILE" ]; then
			log_file "$SYSLOGD_ALTERNATIVE_LOGFILE"
		elif [ -e "/var/log/messages" ]; then
			log_file "/var/log/messages"
		fi
	fi
else
	echo '<h1>$(lang de:"Kein lokales Loggen aktiviert" en:"No local logging enabled")!</h1>'
fi

