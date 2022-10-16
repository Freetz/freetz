#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype "enabled" "$KNOCK_ENABLED" "" "" 0

sec_end
sec_begin 'Port-Knock Server'

cat << EOF
<h2>$(lang de:"Der Port-Knock Server h&ouml;rt an:" en:"Knockd server listens on:")</h2>
<p>Interface: <input type="text" name="interface" size="6" maxlength="8" value="$(html "$KNOCK_INTERFACE")"></p>
EOF

sec_end
