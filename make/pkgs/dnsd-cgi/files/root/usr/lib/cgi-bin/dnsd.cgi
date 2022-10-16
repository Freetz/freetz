#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$DNSD_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"dnsd" en:"dnsd")"

cat << EOF
<table border="0">
<tr>
	<td>$(lang de:"TTL" en:"TTL"):</td>
	<td><input type="text" name="ttl" size="10" maxlength="10" value="$(html "$DNSD_TTL")"></td>
</tr>
<tr>
	<td>$(lang de:"Port" en:"Port"):</td>
	<td><input type="text" name="port" size="10" maxlength="10" value="$(html "$DNSD_PORT")"></td>
</tr>
<tr>
	<td>$(lang de:"Adresse" en:"Address"):</td>
	<td><input type="text" name="addr" size="20" maxlength="20" value="$(html "$DNSD_ADDR")"></td>
</tr>
<tr>
	<td>$(lang de:"Erweiterte Optionen" en:"Extra options"):</td>
	<td><input type="text" name="extra" size="40" maxlength="40" value="$(html "$DNSD_EXTRA")"></td>
</tr>
</table>
EOF

sec_end
