#!/bin/sh

. /usr/lib/libmodcgi.sh


#

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype "enabled" "$TINC_ENABLED" "" "" 0

sec_end

#

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cgi_print_textline_p "server0" "$TINC_SERVER0" 25/255 "$(lang de:"Alias dieses Servers" en:"Alias of this server"): "

cgi_print_textline_p "server1" "$TINC_SERVER1" 25/255 "$(lang de:"Alias von Server 1" en:"Alias of server 1"): "
cgi_print_textline_p "server2" "$TINC_SERVER2" 25/255 "$(lang de:"Alias von Server 2" en:"Alias of server 2"): "
cgi_print_textline_p "server3" "$TINC_SERVER3" 25/255 "$(lang de:"Alias von Server 3" en:"Alias of server 3"): "

sec_end

#

sec_begin "$(lang de:"Erweitert" en:"Advanced")"

cgi_print_textline_p "addr" "$TINC_ADDR" 35/255 "$(lang de:"Binden an" en:"Bind to") (IP): "
cgi_print_textline_p "port" "$TINC_PORT" 5/6 "$(lang de:"Port" en:"Port"): "

sec_end

#

sec_begin "$(lang de:"Loggen" en:"Logging")"

cgi_print_textline_p "debuglevel" "$TINC_DEBUGLEVEL" 1/1 "$(lang de:"Debuglevel" en:"Debug level") (0-5): "

cgi_print_checkbox_p "logfile_enabled" "$TINC_LOGFILE_ENABLED" "$(lang de:"In Datei loggen" en:"Log to file")"
cgi_print_textline_p "logfile_name" "$TINC_LOGFILE_NAME" 55/255 "$(lang de:"Logdatei" en:"Log file"): "


sec_end
