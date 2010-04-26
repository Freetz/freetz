#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

stat_button() {
	echo '<form action="/cgi-bin/exec.cgi" method="post"><p><input type="hidden" name="cmd" value="'"$1"'"><input type="submit" value="'"$2"'"></p></form>'
}

cgi_begin 'System' system

echo "<h1>$(lang de:"Box neustarten" en:"Restart box")</h1>"
stat_button reboot '$(lang de:"Reboot" en:"Reboot")'

echo "<h1>$(lang de:"Nicht unterstützte Änderungen" en:"Unauthorized changes")</h1>"
cat << EOF
<p>$(lang
    de:"Diese Warnung lässt sich hier zurücksetzen."
    en:"This warning can be reset here."
)</p>
EOF

# stat_button cleanup '$(lang de:"TFFS aufräumen" en:"Clean up TFFS")'
stat_button fw_attrib '$(lang de:"Warnung zurücksetzen" en:"Reset warning")'

cgi_end
