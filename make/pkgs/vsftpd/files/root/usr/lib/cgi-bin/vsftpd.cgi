#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$VSFTPD_ANONYMOUS" yes:anonym
check "$VSFTPD_USERS_ENABLED" yes:users_enabled
check "$VSFTPD_CHROOT" yes:chroot
check "$VSFTPD_ALLOW_ROOT" yes:root
check "$VSFTPD_ALLOW_FTPUSER" yes:ftpuser
check "$VSFTPD_PROMISCUOUS" yes:promiscuous
check "$VSFTPD_LOG_ENABLE" yes:log_enable
check "$VSFTPD_LOG_PROTOC" yes:log_protoc
check "$VSFTPD_LOG_SYSLOG" yes:log_syslog_yes "*":log_syslog_no
check "$VSFTPD_ENABLE_SSL" yes:ssl
check "$VSFTPD_ENABLE_SSLV2" yes:sslv2
check "$VSFTPD_ENABLE_SSLV3" yes:sslv3
check "$VSFTPD_ENABLE_TLSV1" yes:tlsv1
check "$VSFTPD_FORCE_DATA_SSL" yes:data_ssl
check "$VSFTPD_FORCE_LOGIN_SSL" yes:login_ssl
check "$VSFTPD_ENABLE_RELOAD_SCRIPT" yes:reload_script
check "$VSFTPD_PASV_ADDRESS" yes:pasv_add
check "$VSFTPD_SHOW_BANNER" yes:show_banner

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$VSFTPD_ENABLED" "" "" 1
sec_end

if [ "$VSFTPD_LOG_SYSLOG" != "yes" ]; then
sec_begin "$(lang de:"Anzeigen" en:"Show")"

cat << EOF
<ul>
<li><a href="$(href status vsftpd vsftpd_log)">$(lang de:"Logdatei anzeigen" en:"Show logfile")</a></li>
</ul>
EOF

sec_end
fi

sec_begin "$(lang de:"FTP Server" en:"FTP server")"

cat << EOF
<p> $(lang de:"Server binden an Port" en:"Listen on port"): <input type="text" name="port" size="5" maxlength="5" value="$(html "$VSFTPD_PORT")"></p>
EOF

sec_end
sec_begin "$(lang de:"Zugriff" en:"Access")"

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
<input id="a4" type="checkbox" name="allow_root" value="yes"$root_chk><label for="a4"> $(lang de:"Erlaube root login" en:"Allow root login")</label>
<input type="hidden" name="allow_ftpuser" value="no">
<input id="a5" type="checkbox" name="allow_ftpuser" value="yes"$ftpuser_chk><label for="a5"> $(lang de:"Erlaube ftpuser login" en:"Allow ftpuser login")</label>
</p>
EOF

sec_end
if [ "$FREETZ_PACKAGE_VSFTPD_WITH_SSL" == "y" ]; then
sec_begin "$(lang de:"SSL-Einstellungen" en:"SSL Settings")"

cat << EOF
<p>
<input type="hidden" name="enable_ssl" value="no">
<input id="s1" type="checkbox" name="enable_ssl" value="yes"$ssl_chk><label for="s1"> $(lang de:"SSL aktivieren" en:"enable SSL")</label>
<p style="font-size:10px;">$(lang de:"Damit VSFTPD mit SSL-Unterst&uuml;tzung gestartet werden kann, m&uuml;ssen Zertifikat&amp;Schl&uuml;ssel <a href=\"$(href file vsftpd crt)\">hier</a> eingetragen sein." en:"To start VSFTPD with SSL-Support you have to setup Certifikat&amp;Key <a TARGET=\"_blank\" href=\"$(href file vsftpd crt)\">hier</a>.")</p>
</p>
<p>
<input type="hidden" name="enable_sslv2" value="no">
<input id="s2" type="checkbox" name="enable_sslv2" value="yes"$sslv2_chk><label for="s2"> $(lang de:"erlaube SSLv2" en:"permit SSL v2")</label>
<input type="hidden" name="enable_sslv3" value="no">
<input id="s3" type="checkbox" name="enable_sslv3" value="yes"$sslv3_chk><label for="s3"> $(lang de:"erlaube SSLv3" en:"permit SSL v3")</label>
<input type="hidden" name="enable_tlsv1" value="no">
<input id="s4" type="checkbox" name="enable_tlsv1" value="yes"$tlsv1_chk><label for="s4"> $(lang de:"erlaube TLSv1" en:"permit TLS v1")</label>
</p>
<p>
<input type="hidden" name="force_data_ssl" value="no">
<input id="s5" type="checkbox" name="force_data_ssl" value="yes"$data_ssl_chk><label for="s5"> $(lang de:"lokale Benutzer zwingen eine SSL-Verbindung f&uuml;r den Datenverkehr zu nutzen" en:"force users to use a secure SSL connection to send and recieve data")</label><br>
<input type="hidden" name="force_login_ssl" value="no">
<input id="s6" type="checkbox" name="force_login_ssl" value="yes"$login_ssl_chk><label for="s6"> $(lang de:"lokale Benutzer zwingen eine SSL-Verbindung f&uuml;r den Login zu nutzen" en:"force users to use a secure SSL connection to login")</label>
</p>
EOF

sec_end
fi
sec_begin "$(lang de:"Erweiterte Einstellungen" en:"Advanced Options")"

cat << EOF
<p>
$(lang de:"Anzahl Verbindungen" en:"Maximum connections"):
&nbsp;
<label for="b1">$(lang de:"insgesamt" en:"overall")
<input type="text" name="max_clients" size="5" maxlength="5" value="$(html "$VSFTPD_MAX_CLIENTS")"></label>
&nbsp;
<label for="b2">$(lang de:"pro Client" en:"per client")
<input type="text" name="max_per_ip" size="5" maxlength="5" value="$(html "$VSFTPD_MAX_PER_IP")"></label>
</p>
<p>
$(lang de:"Passive Ports" en:"Passive ports"):
&nbsp;
<label for="b3">$(lang de:"Minimum" en:"minimum")
<input type="text" name="pasv_min" size="5" maxlength="5" value="$(html "$VSFTPD_PASV_MIN")"></label>
&nbsp;
<label for="b4">$(lang de:"Maximum" en:"maximum")
<input type="text" name="pasv_max" size="5" maxlength="5" value="$(html "$VSFTPD_PASV_MAX")"></label>
</p>
<p>
<input type="hidden" name="promiscuous" value="no">
<input id="b5" type="checkbox" name="promiscuous" value="yes"$promiscuous_chk><label for="b5"> $(lang de:"FXP aktivieren" en:"Enable FXP")</label>
<input type="hidden" name="show_banner" value="no">
<input id="b6" type="checkbox" name="show_banner" value="yes"$show_banner_chk><label for="b6"> $(lang de:"Banner anzeigen" en:"Show banner")</label>
</p>
<p>
$(lang de:"Pause nach fehlerhaftem Login in Sekunden:" en:"Delay after failed login in sec:") <input type="text" name="delay_failed_login" size="5" maxlength="5" value="$(html "$VSFTPD_DELAY_FAILED_LOGIN")">
</p>
<p>
$(lang de:"Die beiden folgenden Einstellungen werden haupts&auml;chlich f&uuml;r den Betrieb mit SSL-Verschl&uuml;sselung ben&ouml;tigt, da die Firewall dem Verkehr nicht mehr folgen kann." en:"The following 2 settings are mainly for operating with SSL, because the firewall can't follow the encrypted traffic.")<br>
<input type="hidden" name="pasv_address" value="no">
<input id="a2" type="checkbox" name="pasv_address" value="yes"$pasv_add_chk><label for="a2"> $(lang de:"aktuelle &ouml;ffentliche IP als pasv_address eintragen" en:"write actual public IP as pasv_address to config")</label><br>
<input type="hidden" name="enable_reload_script" value="no">
<input id="a3" type="checkbox" name="enable_reload_script" value="yes"$reload_script_chk><label for="a3"> $(lang de:"Script /etc/onlinechanged/reload_vsftpd aktivieren, damit die Konfiguration nach einem IP-Wechsel neu generiert wird." en:"Create script /etc/onlinechanged/reload_vsftpd to recreate config after IP-change.")</label>
</p>
EOF

sec_end
sec_begin "$(lang de:"Zus&auml;tzliche Konfigurationsoptionen (f&uuml;r Experten)" en:"Additional config options (for experts)")"

cat << EOF
$(lang de:"Mehr Infos: <a TARGET=\"_blank\" href=\"http://vsftpd.beasts.org/vsftpd_conf.html\">hier</a>" en:"more information: <a TARGET=\"_blank\" http://vsftpd.beasts.org/vsftpd_conf.html\">here</a>")</font><br />
<p><textarea name="add_settings" rows="2" cols="50" maxlength="255">$(html "$VSFTPD_ADD_SETTINGS")</textarea></p>
EOF

sec_end
sec_begin "$(lang de:"Logging" en:"Logging")"

cat << EOF

<p>
<input type="hidden" name="log_enable" value="no">
<input id="l1" type="checkbox" name="log_enable" value="yes"$log_enable_chk><label for="l1"> $(lang de:"Logging aktivieren" en:"Enable logging")</label>
<br>
<input type="hidden" name="log_protoc" value="no">
<input id="l2" type="checkbox" name="log_protoc" value="yes"$log_protoc_chk><label for="l2"> $(lang de:"zus&auml;tzlich Protokoll-Log" en:"Extend by protocol-log")</label>
</p>

<p>
<input id="p1" type="radio" name="log_syslog" value="yes"$log_syslog_yes_chk><label for="x1">$(lang de:"Syslog" en:"Syslog")</label><br>
<input id="p2" type="radio" name="log_syslog" value="no"$log_syslog_no_chk><label for="x2">$(lang de:"Datei:&nbsp;" en:"File:&nbsp;&nbsp;")
<input type="text" name="log_file" size="45" maxlength="255" value="$(html "$VSFTPD_LOG_FILE")"></label>
</p>


EOF


sec_end
sec_begin "$(lang de:"Chroot_List" en:"chroot_list")"

cat << EOF
<p style="font-size:10px;">$(lang de:"F&uuml;ge alle Nutzer in die Liste ein, die ein chroot jail gesperrt werden sollen. Falls du 'chroot jail' aktiviert hast, &auml;ndert sich die Bedeutung der Liste. Alle User in der Liste werden dann NICHT in das chroot jail geschlossen." en:"Put all local users in the list who should be placed in a chroot jail in their home directory upon login. The meaning is slightly different if 'chroot jail' is set to YES. In this case, the list becomes a list of users which are NOT to be placed in a chroot() jail.")</p>
<p><textarea name="chroot_jail_list" rows="2" cols="50" maxlength="255">$(html "$VSFTPD_CHROOT_JAIL_LIST")</textarea></p>
EOF

sec_end

