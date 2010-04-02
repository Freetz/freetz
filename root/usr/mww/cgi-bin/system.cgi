#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

stat_button() {
	echo '<div class="btn"><form class="btn" action="/cgi-bin/exec.cgi" method="post"><input type="hidden" name="cmd" value="'"$1"'"><input type="submit" value="'"$2"'"></form></div>'
}

cgi_begin 'System' system

# stat_button cleanup '$(lang de:"TFFS aufräumen" en:"Clean up TFFS")'
stat_button fw_attrib '$(lang de:"Attribute bereinigen" en:"Clean up attributes")'

cgi_end
