#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$DNSD_ENABLED" yes:auto "*":man

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
cat << EOF
</p>
EOF

sec_end
sec_begin '$(lang de:"dnsd" en:"dnsd")'

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
