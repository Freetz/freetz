#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$RCAPID_ENABLED" "" "" 1
sec_end

sec_begin "$(lang de:"Remote CAPI Daemon" en:"Remote CAPI daemon")"

cat << EOF
<h2>$(lang de:"Der Remote CAPI Daemon ist gebunden an" en:"The remote CAPI daemon is listening on"):</h2>
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$RCAPID_PORT")"></p>
EOF

sec_end
