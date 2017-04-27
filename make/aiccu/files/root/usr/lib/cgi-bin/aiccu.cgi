#!/bin/sh

. /usr/lib/libmodcgi.sh

check "$AICCU_RUNSCRIPT"   yes:runscript

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cgi_print_radiogroup_service_starttype "enabled" "$AICCU_ENABLED" "" "" 0
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
sec_begin '$(lang de:"Erweitert" en:"Advanced")'

cat << EOF
<p>
<input type="hidden" name="runscript" value="no">
<input id="a1" type="checkbox" name="runscript" value="yes"$runscript_chk><label for="a1">$(lang de:"Nach Verbindungsaufbau aiccu.sh ausf&uuml;hren." en:"Run aiccu.sh after the connection was established.")</label>
<FONT SIZE=-2>($(lang de:"Als Parameter wird das Interface &uuml;bergeben" en:"Executed with the interface as parameter."))</FONT>
</p>
<p>$(lang de:"Maximal solange warten bis die Zeit synchronisiert ist (Sekunden)" en:"Maximal time waiting for time-synchronisation (seconds)"): <input type="text" name="waittime" size="2" maxlength="5" value="$(html "$AICCU_WAITTIME")"></p>
EOF

sec_end
