#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$AICCU_ENABLED" yes:auto "*":man

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
sec_begin '$(lang de:"aiccu" en:"aiccu")'

cat << EOF
<table border="0">
<tr>
	<td>$(lang de:"Benutzername" en:"Username"):</td>
	<td><input type="text" name="username" size="15" maxlength="50" value="$(html "$AICCU_USERNAME")"></td>
</tr>
<tr>
	<td>$(lang de:"Passwort" en:"Password"):</td>
	<td><input type="password" name="password" size="15" maxlength="50" value="$(html "$AICCU_PASSWORD")"></td>
</tr>
<tr>
	<td>$(lang de:"Tunnel ID" en:"Tunnel Id"):</td>
	<td><input type="text" name="tunnelid" size="15" maxlength="50" value="$(html "$AICCU_TUNNELID")"></td>
</tr>
<tr>
	<td>$(lang de:"Name des virt. IPv6 Interface" en:"Name of virtual IPv6 interface"):</td>
	<td><input type="text" name="interface" size="15" maxlength="16" value="$(html "$AICCU_INTERFACE")"></td>
</tr>
</table>
EOF

sec_end
