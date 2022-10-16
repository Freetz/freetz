#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$HD_IDLE_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Optionen" en:"Options")"
cat << EOF
<p>
<label for="idletime">$(lang de:"Leerlaufzeit" en:"Idle time"):</label>
<input id="idletime" size="5" maxlength="8" type="text" name="idletime" value="$(html "$HD_IDLE_IDLETIME")"> $(lang de:"Sekunden" en:"seconds")
</p>
EOF
sec_end
