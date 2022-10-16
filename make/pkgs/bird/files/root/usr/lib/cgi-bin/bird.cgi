#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype "enabled" "$BIRD_ENABLED" "" "" 0

cat << EOF
<p>
$(lang de:"Startverz&ouml;gerung (Sekunden)" en:"Start delay (seconds)"): <input id="autostartdelay" size="4" maxlength="3" type="text" name="autostartdelay" value="$(html "$BIRD_AUTOSTARTDELAY")">
<br/>
<small>$(lang de:"Bezieht sich nur auf den Starttyp 'Automatisch'. Gibt z.B. OpenVPN die Chance, den/die VPN-Tunnel aufzubauen." en:"Applies only to start type 'automatic'. Gives e.g. OpenVPN a chance to establish VPN tunnels")</small>
</p>
EOF

sec_end

if [ ! -f /etc/bird.conf ]; then
sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<ul><li><a href="$(href file bird conf)">$(lang de:"bird.conf bearbeiten" en:"Edit bird.conf")</a></li></ul>
EOF

sec_end
fi
