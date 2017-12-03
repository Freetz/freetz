#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin '$(lang de:"Starttyp" en:"Start type")' sec_start
cgi_print_radiogroup_service_starttype "enabled" "$WIREGUARD_ENABLED" "" "" 0
sec_end

sec_begin '$(lang de:"Einstellungen" en:"Configuration")'
cgi_print_textline_p "ip" "$WIREGUARD_IP" 20/255 "$(lang de:"IP-Adresse" en:"IP address"):"
sec_end
