#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh


auto_chk=''; man_chk=''

if [ "$VIRTUALIP_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi


sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>$(lang de:"Starttyp" en:"Start type")<br />
<input id="auto1" type="radio" name="enabled" value="yes"$auto_chk><label for="auto1">$(lang de:"Automatisch" en:"Automatic")</label>
<input id="auto2" type="radio" name="enabled" value="no"$man_chk><label for="auto2">$(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Netwerkeinstellungen" en:"Network settings")'

cat << EOF
<p>$(lang de:"Virtuelle IP-Adresse" en:"Virtual IP-Adress"): <input id="ip" type="text" name="ip" value="$(html "$VIRTUALIP_IP")">
<br />$(lang de:"Subnetzmaske" en:"Subnet Mask"): <input id="netmask" type="text" name="netmask" value="$(html "$VIRTUALIP_NETMASK")">
<br />$(lang de:"Interface" en:"Interface"): <input id="interface" type="text" name="interface" value="$(html "$VIRTUALIP_INTERFACE")"></p>
EOF

sec_end
