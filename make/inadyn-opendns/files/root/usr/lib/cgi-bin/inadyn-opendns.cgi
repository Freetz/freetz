#!/bin/sh

. /usr/lib/libmodcgi.sh


#

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype \
	"enabled" "$INADYN_OPENDNS_ENABLED" "" "" 0

sec_end

#

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cgi_print_textline_p "cmdline" "$INADYN_OPENDNS_CMDLINE" 55/250 "$(lang de:"Optionale Parameter (au&szlig;er --input_file)" en:"Optional parameters (except --input_file)"): "
cgi_print_textline_p "user"    "$INADYN_OPENDNS_USER"    15/50 "$(lang de:"Benutzername" en:"Username"): "
cgi_print_textline_p "pass"    "$INADYN_OPENDNS_PASS"    15/50 "$(lang de:"Passwort" en:"Password"): "
cgi_print_textline_p "alias"   "$INADYN_OPENDNS_ALIAS"   25/50 "$(lang de:"Alias" en:"Alias"): "

sec_end

