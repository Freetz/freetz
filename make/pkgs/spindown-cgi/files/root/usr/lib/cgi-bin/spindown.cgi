#!/bin/sh

. /usr/lib/libmodcgi.sh

check "$SPINDOWN_MODE" 3:mode3 "*":mode5

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SPINDOWN_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Optionen" en:"Options")"
cat << EOF
<p><label for="device">$(lang de:"Ger&auml;tename" en:"Device name"):</label> <input
id="device" size="10" maxlength="15" type="text" name="device"
value="$(html "$SPINDOWN_DEVICE")"></p>
<p><label for="idletime">$(lang de:"Leerlaufzeit" en:"Idle time"):</label> <input
id="idletime" size="5" maxlength="8" type="text" name="idletime"
value="$(html "$SPINDOWN_IDLETIME")"> $(lang de:"Sekunden" en:"seconds")</p>
<p>$(lang de:"Modus" en:"Mode"): <input id="p1" type="radio" name="mode" value="3"$mode3_chk> <label
for="p1">Standby</label></input>
<input id="p2" type="radio" name="mode" value="5"$mode5_chk> <label
for="p2">Sleep</label></input></p>
EOF
sec_end
