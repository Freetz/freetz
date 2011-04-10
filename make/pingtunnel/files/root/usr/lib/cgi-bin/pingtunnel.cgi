#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$PINGTUNNEL_ENABLED" yes:auto "*":man

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end

sec_begin '$(lang de:"Server" en:"Server")'
cat << EOF
<p>$(lang de:"Tunnel-Passwort" en:"Tunnel password"): <input type="password" name="password" size="20" maxlength="32" value="$(html "$PINGTUNNEL_PASSWORD")"></p>
<p>$(lang de:"Erweiterte Optionen" en:"Extra options"): <input type="text" name="extra" size="40" maxlength="255" value="$(html "$PINGTUNNEL_EXTRA")"></p>
EOF

sec_end
