#!/bin/sh


. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SMSTOOLS3_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"SMS senden und empfangen" en:"Send and receive SMS")"
cat << EOF
<ul>
<li><a href="$(href status smstools3)">$(lang de:"Hier klicken f&uuml;r Statusseite" en:"Click here for status page").</a></li>
</ul>
EOF
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"
cgi_print_textline_p "dir"      "$SMSTOOLS3_DIR"      50/255 \
  "$(lang de:"Datenverzeichnis" en:"data directory"): "
cgi_print_textline_p "events"   "$SMSTOOLS3_EVENTS"   50/255 \
  "$(lang de:"Event-Handler" en:"event handler"): "
cgi_print_textline_p "device"   "$SMSTOOLS3_DEVICE"   15/255 \
  "$(lang de:"UMTS-Ger&auml;t" en:"UMTS device"): "
cgi_print_textline_p "pin"      "$SMSTOOLS3_PIN"      8      \
  "PIN: " " ($(lang de:"leer lassen wenn deaktiviert" en:"leave empty if deactivated"))"
cgi_print_textline_p "loglevel" "$SMSTOOLS3_LOGLEVEL" 1      \
  "$(lang de:"Loglevel" en:"Log level"): "
sec_end
