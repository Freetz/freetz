#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$RADVD_ENABLED" yes:auto "*":man
check "$RADVD_FORWARD" yes:forward
check "$RADVD_SETIPV6" yes:setipv6
check "$RADVD_DELIPV6" yes:delipv6

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
sec_begin '$(lang de:"radvd" en:"radvd")'

cat << EOF
<table border="0">
<tr>
	<td>$(lang de:"IPv6 Schnittstelle" en:"IPv6 interface"):</td>
	<td><input type="text" name="interface" size="15" maxlength="16" value="$(html "$RADVD_INTERFACE")"></td>
</tr>
<tr>
	<td>$(lang de:"IPv6 Adresse" en:"IPv6 address"):</td>
	<td><input type="text" name="address" size="30" maxlength="100" value="$(html "$RADVD_ADDRESS")"></td>
</tr>
<tr>
	<td>$(lang de:"IPv6 Prefix" en:"IPv6 prefix"):</td>
	<td><input type="text" name="prefix" size="30" maxlength="100" value="$(html "$RADVD_PREFIX")"></td>
</tr>
</table>
<p>
<input type="hidden" name="forward" value="no">
<input id="c1" type="checkbox" name="forward" value="yes"$forward_chk>
<label for="c1">$(lang de:"IPv6 Forwarding im Kernel aktivieren beim Starten bzw deaktivieren beim Stoppen." en:"Activate on start resp. deactivate on stop the IPv6 forwarding.")</label>
</p>
<p>
<input type="hidden" name="setipv6" value="no">
<input id="c2" type="checkbox" name="setipv6" value="yes"$setipv6_chk>
<label for="c2">$(lang de:"IPv6 Adresse der Schnittstelle beim Starten setzen." en:"Set on start the IPv6 address of the interface.")</label>
</p>
<p>
<input type="hidden" name="delipv6" value="no">
<input id="c3" type="checkbox" name="delipv6" value="yes"$delipv6_chk>
<label for="c3">$(lang de:"IPv6 Adresse der Schnittstelle beim Stoppen entfernen." en:"Unset on stop the IPv6 address of the interface.")</label>
</p>
EOF

sec_end
