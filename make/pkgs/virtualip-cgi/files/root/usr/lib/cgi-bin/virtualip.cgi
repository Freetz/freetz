#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$VIRTUALIP_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Netwerkeinstellungen" en:"Network settings")"

cat << EOF
<p>$(lang de:"Virtuelle IP-Adresse" en:"Virtual IP-Adress"): <input id="ip" type="text" name="ip" value="$(html "$VIRTUALIP_IP")">
<br />$(lang de:"Subnetzmaske" en:"Subnet Mask"): <input id="netmask" type="text" name="netmask" value="$(html "$VIRTUALIP_NETMASK")">
<br />$(lang de:"Interface" en:"Interface"): <input id="interface" type="text" name="interface" value="$(html "$VIRTUALIP_INTERFACE")"></p>
EOF

sec_end
