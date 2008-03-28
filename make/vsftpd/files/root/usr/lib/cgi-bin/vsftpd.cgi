#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''; inetd_chk=''
anonym_chk='';users_enabled_chk='';chroot_chk='';root_chk=''
log_enable_chk='';log_protoc_chk='';log_syslog_yes='';log_syslog_no=''
promiscuous_chk=''

case "$VSFTPD_ENABLED" in yes) auto_chk=' checked';; inetd) inetd_chk=' checked';; *) man_chk=' checked';;esac
if [ "$VSFTPD_ANONYMOUS" = "yes" ]; then anonym_chk=' checked'; fi
if [ "$VSFTPD_USERS_ENABLED" = "yes" ]; then users_enabled_chk=' checked'; fi
if [ "$VSFTPD_CHROOT" = "yes" ]; then chroot_chk=' checked'; fi
if [ "$VSFTPD_ALLOW_ROOT" = "yes" ]; then root_chk=' checked'; fi
if [ "$VSFTPD_PROMISCUOUS" = "yes" ]; then promiscuous_chk=' checked'; fi
if [ "$VSFTPD_LOG_ENABLE" = "yes" ]; then log_enable_chk=' checked'; fi
if [ "$VSFTPD_LOG_PROTOC" = "yes" ]; then log_protoc_chk=' checked'; fi
if [ "$VSFTPD_LOG_SYSLOG" = "yes" ]; then log_syslog_yes=' checked'; else log_syslog_no=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
if [ -e "/etc/default.inetd/inetd.cfg" ]; then
cat << EOF
<input id="e3" type="radio" name="enabled" value="inetd"$inetd_chk><label for="e3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
fi
cat << EOF
</p>
EOF

sec_end
sec_begin '$(lang de:"FTP Server" en:"FTP server")'

cat << EOF
<p> $(lang de:"Server binden an Port" en:"Listen on port"): <input type="text" name="port" size="5" maxlength="5" value="$(httpd -e "$VSFTPD_PORT")"></p>
EOF

sec_end
sec_begin '$(lang de:"Zugriff" en:"Access")'

cat << EOF
<p style="font-size:10px;">$(lang de:"Das Passwort f&uuml;r den Benutzer 'ftp' kann mit dem Kommando 'passwd ftp' festgelegt und mit 'modusers save; modsave flash' persistent gespeichert werden." en:"The password for the user 'ftp' can be set by using the command 'passwd ftp' and subsequently saved persistently by 'modusers save; modsave flash'.")</p><p>
<input type="hidden" name="anonymous" value="no">
<input id="a1" type="checkbox" name="anonymous" value="yes"$anonym_chk><label for="a1"> $(lang de:"Anonymes FTP" en:"Anonymous FTP")</label>
<input type="hidden" name="users_enabled" value="no">
<input id="a2" type="checkbox" name="users_enabled" value="yes"$users_enabled_chk><label for="a2"> $(lang de:"Lokale Benutzer" en:"Local users")</label>
<input type="hidden" name="chroot" value="no">
<input id="a3" type="checkbox" name="chroot" value="yes"$chroot_chk><label for="a3"> $(lang de:"chroot jail" en:"chroot jail")</label>
</p>
<p>
<input type="hidden" name="allow_root" value="no">
<input id="a1" type="checkbox" name="allow_root" value="yes"$root_chk><label for="a1"> $(lang de:"Erlaube root login" en:"Allow root login")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Erweiterte Einstellungen" en:"Advanced Options")'

cat << EOF
<p>
$(lang de:"Anzahl Verbindungen" en:"Maximum connections"):
&nbsp;
<label for="p1">$(lang de:"insgesamt" en:"overall")
<input type="text" name="max_clients" size="5" maxlength="5" value="$(httpd -e "$VSFTPD_MAX_CLIENTS")"></label>
&nbsp;
<label for="p2">$(lang de:"pro Client" en:"per client")
<input type="text" name="max_per_ip" size="5" maxlength="5" value="$(httpd -e "$VSFTPD_MAX_PER_IP")"></label>
</p>
<p>
$(lang de:"Passive Ports" en:"Passive ports"):
&nbsp;
<label for="p1">$(lang de:"Minimum" en:"minimum")
<input type="text" name="pasv_min" size="5" maxlength="5" value="$(httpd -e "$VSFTPD_PASV_MIN")"></label>
&nbsp;
<label for="p2">$(lang de:"Maximum" en:"maximum")
<input type="text" name="pasv_max" size="5" maxlength="5" value="$(httpd -e "$VSFTPD_PASV_MAX")"></label>
</p>
<p>
<input type="hidden" name="promiscuous" value="no">
<input id="a1" type="checkbox" name="promiscuous" value="yes"$promiscuous_chk><label for="a1"> $(lang de:"FXP aktivieren" en:"Enable FXP")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Logging" en:"Logging")'

cat << EOF

<p>
<input type="hidden" name="log_enable" value="no">
<input id="a1" type="checkbox" name="log_enable" value="yes"$log_enable_chk><label for="a1"> $(lang de:"Logging aktivieren" en:"Enable logging")</label>
<br>
<input type="hidden" name="log_protoc" value="no">
<input id="a2" type="checkbox" name="log_protoc" value="yes"$log_protoc_chk><label for="a2"> $(lang de:"zus&auml;tzlich Protokoll-Log" en:"Extend by protocol-log")</label>
</p>

<p>
<input id="p1" type="radio" name="log_syslog" value="yes"$log_syslog_yes><label for="x1">$(lang de:"Syslog" en:"Syslog")</label><br>
<input id="p2" type="radio" name="log_syslog" value="no"$log_syslog_no><label for="x2">$(lang de:"Datei:&nbsp;" en:"File:&nbsp;&nbsp;")
<input type="text" name="log_file" size="45" maxlength="255" value="$(httpd -e "$VSFTPD_LOG_FILE")"></label>
</p>


EOF


sec_end
