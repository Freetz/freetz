#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$IODINE_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Server" en:"Server")"

cgi_print_textline_p "domain" "$IODINE_DOMAIN" 20/255 \
  "$(lang de:"DNS Domain Name" en:"DNS Domain name"): "

cgi_print_textline_p "dnsport" "$IODINE_DNSPORT" 10/5 \
  "$(lang de:"DNS Portnummer" en:"DNS port number"): "

cgi_print_textline_p "tunip" "$IODINE_TUNIP" 20 \
  "$(lang de:"Server Tunnel-IP" en:"Server tunnel IP"): "

cgi_print_password_p "password" "$IODINE_PASSWORD" 20/32 \
  "$(lang de:"Tunnel-Passwort" en:"Tunnel password"): "

cgi_print_textline_p "extra" "$IODINE_EXTRA" 40/255 \
  "$(lang de:"Erweiterte Optionen" en:"Extra options"): "

sec_end
