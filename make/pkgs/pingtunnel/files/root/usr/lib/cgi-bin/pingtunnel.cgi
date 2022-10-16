#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$PINGTUNNEL_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Server" en:"Server")"

cgi_print_password_p "password" "$PINGTUNNEL_PASSWORD" 20/32 \
  "$(lang de:"Tunnel-Passwort" en:"Tunnel password"): "

cgi_print_textline_p "extra" "$PINGTUNNEL_EXTRA" 40/255 \
  "$(lang de:"Erweiterte Optionen" en:"Extra options"): "

sec_end
