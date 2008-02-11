#!/bin/sh
 
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
if [ "$BIRD_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p><input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label
for="e1"> $(lang de:"Automatisch" en:"Automatic")</label><input id="e2" type="radio"
name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label></p>
<p>$(lang de:"Startverz&ouml;gerung (Sekunden)" en:"Start delay (seconds)"): <input id="autostartdelay"
size="4" maxlength="3" type="text" name="autostartdelay" value="$(httpd -e "$BIRD_AUTOSTARTDELAY")"><br />
<small>$(lang de:"Bezieht sich nur auf den Starttyp 'Automatisch'. Gibt z.B. OpenVPN die
Chance, den/die VPN-Tunnel aufzubauen." en:"Only applies for start type 'automatic'. Gives e.g. OpenVPN a chance to
establish VPN tunnels")</small></p>
EOF

sec_end

if [ ! -f /etc/bird.conf ]; then
sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cat << EOF
<ul><li><a href="/cgi-bin/file.cgi?id=bird_conf">$(lang de:"bird.conf bearbeiten" en:"Edit bird.conf")</a></li></ul>
EOF

sec_end
fi
