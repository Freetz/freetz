#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$RSYNC_ENABLED" yes:auto "*":man
check "$RSYNC_LOG_SYSLOG" yes:log_syslog_yes "*":log_syslog_no

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1">$(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2">$(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Settings")'

cat << EOF
<ul>
<li><a href="$(href file rsync shares)">$(lang de:"Eigene Freigaben" en:"Shares")</a></li>
<li><a href="$(href file rsync sharesx)">$(lang de:"Experten Optionen" en:"Advanced options")</a></li>
</ul>
EOF

sec_end
sec_begin '$(lang de:"RSync" en:"RSync")'

cat << EOF
<p>$(lang de:"Netzwerkschnittstelle" en:"Network interface"):<br>
<input type="text" name="address" size="40" maxlength="255" value="$(html "$RSYNC_ADDRESS")"><br>
<font size="-2">$(lang de:"z.B.: 192.168.178.1 oder leer lassen f&uuml;r alle" en:"For example: 192.168.178.1 or leave blank for all")</font></P>
<p>$(lang de:"Anzahl Verbindungen" en:"Max connections"): <input type="text" name="maxcon" size="5" maxlength="5" value="$(html "$RSYNC_MAXCON")"></p>
<p>
<input id="p1" type="radio" name="log_syslog" value="yes"$log_syslog_yes_chk><label for="x1">$(lang de:"Syslog" en:"Syslog")</label><br>
<input id="p2" type="radio" name="log_syslog" value="no"$log_syslog_no_chk><label for="x2">$(lang de:"Datei:&nbsp;&nbsp;" en:"File:&nbsp;&nbsp;&nbsp;")
<input type="text" name="log_file" size="45" maxlength="255" value="$(html "$RSYNC_LOG_FILE")"></label>
</p>
EOF

sec_end
