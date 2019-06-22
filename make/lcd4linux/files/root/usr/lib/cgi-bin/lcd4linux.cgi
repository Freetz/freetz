#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cgi_print_radiogroup_service_starttype "enabled" "$LCD4LINUX_ENABLED" "" "" 0
sec_end

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'
cat << EOF

<h2>$(lang de:"Ausgabedatei (leer f&uuml;r keine):" en:"Out file (empty for none):")</h2>
<p><input type="text" name="outfile" size="55" maxlength="250" value="$(html "$LCD4LINUX_OUTFILE")"></p>

<h2>$(lang de:"Optionale Parameter (au&szlig;er -o):" en:"Optional parameters (except -o):")</h2>
<p><input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$LCD4LINUX_CMDLINE")"></p>

EOF
sec_end

