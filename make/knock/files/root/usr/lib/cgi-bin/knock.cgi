#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$KNOCK_ENABLED" yes:auto "*":man

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Anzeigen" en:"Show")'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=knockd_conf">$(lang de:"Knockd config bearbeiten" en:"Edit knockd config")</a></li>
</ul>
EOF

sec_end
sec_begin 'Port-Knock Server'

cat << EOF
<h2>$(lang de:"Der Port-Knock Server hört an:" en:"Knockd server listens on:")</h2>
<p>Interface: <input type="text" name="interface" size="6" maxlength="8" value="$(html "$KNOCK_INTERFACE")"></p>
EOF

sec_end
