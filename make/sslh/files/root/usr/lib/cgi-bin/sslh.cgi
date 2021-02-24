#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SSLH_ENABLED" "" "" 1
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cgi_print_textline_p "ports" "$SSLH_PORTS" 55/255 "$(lang de:"Diese Ports &ouml;ffnen (mit Leerzeichen getrennt)" en:"Listen on these ports (space separated)"): "
cgi_print_textline_p "on_timeout" "$SSLH_ON_TIMEOUT" 15/255 "$(lang de:"Bei unbekanntem Protokoll dieses verwenden (zum deaktivieren leer lassen)" en:"On unknown protocol use this (leave empty to decativate)"): "
cgi_print_textline_p "timeout" "$SSLH_TIMEOUT" 2/2 "$(lang de:"Fallback-Timeout (Sek.)" en:"Fallback timeout (sec)"): "
[ "$FREETZ_TARGET_IPV6_SUPPORT" == "y" ] && cgi_print_checkbox_p "ipv6too" "$SSLH_IPV6TOO" "$(lang de:"Auch IPv6 nutzen" en:"Support IPv6 too")"

sec_end
