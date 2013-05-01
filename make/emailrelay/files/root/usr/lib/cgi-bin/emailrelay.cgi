#!/bin/sh

. /usr/lib/libmodcgi.sh


sec_begin '$(lang de:"Starttyp" en:"Start type")'
cgi_print_radiogroup_service_starttype "enabled" "$EMAILRELAY_ENABLED" "" "" 0
sec_end

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'
cgi_print_textline_p "spooldir" "$EMAILRELAY_SPOOLDIR" 55/255 "$(lang de:"Verzeichnis f&uuml;r Spooler" en:"Spool directory"): "
sec_end
