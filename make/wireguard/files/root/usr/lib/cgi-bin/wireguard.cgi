#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin '$(lang de:"Starttyp" en:"Start type")' sec_start
cgi_print_radiogroup_service_starttype "enabled" "$WIREGUARD_ENABLED" "" "" 0
sec_end

sec_begin '$(lang de:"Einstellungen" en:"Configuration")'
cgi_print_textline_p "ip" "$WIREGUARD_IP" 20/255 "$(lang de:"IPv4-Adresse" en:"IPv4 address"): "
cgi_print_textline_p "ip6" "$WIREGUARD_IP6" 35/255 "$(lang de:"IPv6-Adresse" en:"IPv6 address"): "
cat << EOF
<p>$(lang de:"IPv6 leer lassen, wenn nicht vorhanden" en:"Leave IPv6 empty if not applicable")</p>
EOF
sec_end
