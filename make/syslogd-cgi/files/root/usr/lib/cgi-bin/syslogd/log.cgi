#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

. /mod/etc/conf/syslogd.cfg

cgi_begin 'Syslog' 'syslog'

if [ "$SYSLOGD_LOCAL" = "yes" ]; then
if [ "$SYSLOGD_LOGGING" = "circular_buffer" ]; then
	echo '<h1>$(lang de:"Ringpuffer" en:"Memory buffer")</h1>'
	echo -n '<textarea style="width: 500px;" name="content" rows="20" cols="10" wrap="off" readonly>'
	httpd -e "$(logread)"
	echo -n '</textarea>'
else if [ "$SYSLOGD_LOGGING" = "log_to_file" ]; then
	if [ -e "$SYSLOGD_ALTERNATIVE_LOGFILE" ]; then
    	    echo "<h1>$SYSLOGD_ALTERNATIVE_LOGFILE</h1>"
    	    echo -n '<textarea style="width: 500px;" name="content" rows="20" cols="10" wrap="off" readonly>'
	    httpd -e "$(cat $SYSLOGD_ALTERNATIVE_LOGFILE)"
	    echo -n '</textarea>'	    
	else
	    if [ -e "/var/log/messages" ]; then
		echo '<h1>/var/log/messages</h1>'
                echo -n '<textarea style="width: 500px;" name="content" rows="20" cols="10" wrap="off" readonly>'
		httpd -e "$(cat /var/log/messages)"
	    	echo -n '</textarea>'
	    fi
	fi
    fi
fi
else
    echo '<h1>$(lang de:"Kein lokales Loggen aktiviert" en:"No local logging enabled")!</h1>'
fi

cat <<EOF
<form class="btn" action="/cgi-bin/pkgconf.cgi" method="get">
<input type="hidden" name="pkg" value="syslogd">
<div class="btn"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></div>
</form>
EOF

cgi_end
