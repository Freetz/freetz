#!/bin/sh

. /usr/lib/libmodcgi.sh


sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$EMAILRELAY_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"
cat << EOF
<p><textarea name="options" rows="25" cols="65" maxlength="2040">$(html "$EMAILRELAY_OPTIONS")</textarea></p>
EOF
sec_end
