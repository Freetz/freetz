#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi_begin 'Syslog' 'syslog'

echo '<h1>$(lang de:"Hilfe" en:"Help")</h1>'

if [ -r "/sbin/syslogd" ]; then
	echo -n '<textarea style="width: 500px;" name="content" rows="16" cols="60" wrap=off readonly>'
	httpd -e "$(/sbin/syslogd --help)"
	echo -n '</textarea>'
fi

cat <<EOF
<form class="btn" action="/cgi-bin/pkgconf.cgi" method="get">
<input type="hidden" name="pkg" value="syslogd">
<div class="btn"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></div>
</form>
EOF

cgi_end
