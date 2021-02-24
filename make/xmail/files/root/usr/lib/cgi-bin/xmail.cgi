#!/bin/sh

. /usr/lib/libmodcgi.sh

XMAIL_SSLSUPPORT= XMAIL_SSLVISIBLE=

# Check for SSL support
/usr/lib/MailRoot/bin/CtrlClnt 2>&1 | grep -qe ' -S ' && XMAIL_SSLSUPPORT=1
# Check for installed and running PHPXmail
[ -e /mod/etc/init.d/rc.phpxmail ] && XMAIL_PHPXMAIL=1

check "$XMAIL_UNPRIV" yes:unpriv
check "$XMAIL_SMTP" yes:smtp
check "$XMAIL_SSMTP" yes:ssmtp
check "$XMAIL_POP3" yes:pop3
check "$XMAIL_POP3S" yes:pop3s
check "$XMAIL_CTRL" yes:ctrl
check "$XMAIL_CTRLS" yes:ctrls
check "$XMAIL_SMTPLOG" yes:smtplog
check "$XMAIL_POP3LOG" yes:pop3log
check "$XMAIL_SYSTEMLOG" yes:systemlog

[ "$XMAIL_PHPXMAIL" == 1 ] && (
. /usr/lib/libmodredir.sh
sec_begin "$(lang de:"PHPXmail" en:"PHPXmail")"
cat << EOF
<p>$(lang de:"Auf dieser Fritz!Box ist das PHPXMail Webfrontend installiert, klicken sie" en:"On this Fritz!Box is the PHPXMail webfrontend installed, so you can klick") <b><a style='font-size:14px;' target='_blank' href=/phpxmail/index.php>$(lang de:"hier" en:"here")</a></b>$(lang de:", um es zu starten." en:" to start it.")<p>
EOF
sec_end
)

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$XMAIL_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Zentrale Serverkonfiguration" en:"Core server configuration")"
cat << EOF
<p><input type="hidden" name="unpriv" value="no">
<input id="u1" type="checkbox" name="unpriv" value="yes"$unpriv_chk><label for="u1"> $(lang de:"XMail mit unpriviligierter Benutzer ID starten" en:"Start XMail with unprivileged user ID")</label></p>
<hr>
<p style="font-size:10px;">$(lang de:"Bitte gib hier den Speicherort f&uuml;r XMail an (enth&auml;lt alle Email-Boxen, Spool Verzeichnisse, Konfigurationsdateien). Dieses Verzeichnis muss beschreibbar und bereits vorhanden sein. Falls das Verzeichnis leer ist, wird automatisch die richtige Dateistruktur erstellt. Dieses Verzeichnis wird alle Konfigurationsdateien von XMail enthalten, welche manuell (oder via einem Webfrontend) bearbeitet werden m&uuml;ssen." en:"Please provide the storage location for XMail (this location contains all email boxes, spool storage, configuration files). This directory must be writeable and exist. In case the directory is empty, the proper directory structure will be created. This directory will contain all configuration files for XMail which must be modified directly or via a web frontend.")</p>
<p> $(lang de:"Verzeichnis f&uuml;r XMail" en:"Directory for XMail"): <input type="text" name="maillocation" size="30" maxlength="255" value="$(html "$XMAIL_MAILLOCATION")"></p>
<hr>
<p style="font-size:10px;">$(lang de:"Bitte &auml;ndern Sie diese Werte nur wenn Sie wissen was Sie tun." en:"Please change these values only if you know what you are doing.")</p>
<p> $(lang de:"Startparameter" en:"Start parameters"): <input type="text" name="special" size="55" maxlength="255" value="$(html "$XMAIL_SPECIAL")"></p>
EOF
sec_end

sec_begin "$(lang de:"Angebotene Dienste" en:"Offered services")"
cat << EOF
<p style="font-size:10px;">$(lang de:"Bitte beachte: Wenn XMail mit einer unpriviligierten Benutzer-ID gestartet wird, m&uuml;ssen alle hier angegebenen Ports gr&ouml;sser oder gleich 1024 sein, da ansonsten der Dienst nicht startet. Um Dienste aus dem Internet zug&auml;nglich zu machen, musst du eine Port-Weiterleitung mit der Fritz!Box Firewall einrichten (z.B. von Port 25 auf der Internet-Seite zum Port 10025 auf der lokalen Seite)." en:"Please note: If XMail is started with an unprivileged user ID, all ports must be above or equal to 1024 as otherwise the service will not be started. To make services available from the Internet, please use the port forwarding with the Fritz!Box firewall (e.g. from port 25 on the Internet side to port 10025 on the local side.")</p>
<hr>
<p><input type="hidden" name="smtp" value="no">
<input id="a1" type="checkbox" name="smtp" value="yes"$smtp_chk><label for="a1"> $(lang de:"SMTP aktivieren" en:"Activate SMTP")</label></p>
<p> $(lang de:"SMTP Port" en:"SMTP port"): <input type="text" name="smtpport" size="5" maxlength="5" value="$(html "$XMAIL_SMTPPORT")"></p>
EOF
[ "$XMAIL_SSLSUPPORT" == 1 ] &&
cat << EOF
<hr>
<p style="font-size:10px;">$(lang de:"Soll ein weiterer Port f&uuml;r SSL/TLS gesch&uuml;tztes SMTP aktiviert werden (SSL/TLS ist auch am normalen Port verf&uuml;gbar)?" en:"Shall another port for SSL/TLS protected SMTP be activated (SSL/TLS is also available using the regular port)?")</p>
<p><input type="hidden" name="ssmtp" value="no">
<input id="a2" type="checkbox" name="ssmtp" value="yes"$ssmtp_chk><label for="a2"> $(lang de:"SSMTP aktivieren" en:"Activate SSMTP")</label></p>
<p> $(lang de:"SSMTP Port" en:"SSMTP port"): <input type="text" name="ssmtpport" size="5" maxlength="5" value="$(html "$XMAIL_SSMTPPORT")"></p>
EOF
cat << EOF
<hr>
<p><input type="hidden" name="pop3" value="no">
<input id="a3" type="checkbox" name="pop3" value="yes"$pop3_chk><label for="a3"> $(lang de:"POP3 aktivieren" en:"Activate POP3")</label></p>
<p> $(lang de:"POP3 Port" en:"POP3 port"): <input type="text" name="pop3port" size="5" maxlength="5" value="$(html "$XMAIL_POP3PORT")"></p>
EOF
[ "$XMAIL_SSLSUPPORT" == 1 ] &&
cat << EOF
<hr>
<p style="font-size:10px;">$(lang de:"Soll ein weiterer Port f&uuml;r SSL/TLS gesch&uuml;tztes POP3 aktiviert werden (SSL/TLS ist auch am normalen Port verf&uuml;gbar)?" en:"Shall another port for SSL/TLS protected POP3 be activated (SSL/TLS is also available using the regular port)?")</p>
<p><input type="hidden" name="pop3s" value="no">
<input id="a4" type="checkbox" name="pop3s" value="yes"$pop3s_chk><label for="a3"> $(lang de:"POP3S aktivieren" en:"Activate POP3S")</label></p>
<p> $(lang de:"POP3S Port" en:"POP3S port"): <input type="text" name="pop3sport" size="5" maxlength="5" value="$(html "$XMAIL_POP3SPORT")"></p>
EOF
cat << EOF
<hr>
<p style="font-size:10px;">$(lang de:"Bitte beachte: Der SSL-gesch&uuml;tzte Admin Zugang ist aus allen Netzen zug&auml;nglich (port 6018). Der ungesch&uuml;tzte Admin Zugang (6017) ist nur via localhost erreichbar." en:"Please note: The SSL protected admin access is available from all networks (port 6018). The unprotected admin access is available via localhost only (port 6017).")</p>
<p><input type="hidden" name="ctrl" value="no">
<input id="a5" type="checkbox" name="ctrl" value="yes"$ctrl_chk><label for="a5"> $(lang de:"Unverschl&uuml;sselten Admin Zugang aktivieren" en:"Activate unencrypted admin access")</label></p>
EOF
[ "$XMAIL_SSLSUPPORT" == 1 ] &&
cat << EOF
<p style="font-size:10px;">$(lang de:"Soll SSL/TLS gesch&uuml;tzter Admin Zugang aktiviert werden?" en:"Shall SSL/TLS protected admin access be activated?")</p>
<p><input type="hidden" name="ctrls" value="no">
<input id="a6" type="checkbox" name="ctrls" value="yes"$ctrls_chk><label for="a6"> $(lang de:"SSL Admin Zugang aktivieren" en:"Activate SSL admin access")</label></p>
EOF
[ -e $XMAIL_MAILLOCATION/ctrlaccounts.tab ] && [ -z "$(sed -ne 's/ *//g;/\".*\"\t\".*\"/p' $XMAIL_MAILLOCATION/ctrlaccounts.tab)" ] &&
cat << EOF
<p style="font-size:10px;">$(lang de:"Momentan sind keine XMail Administratoren angelegt. Wenn Sie jetzt den Standard-Administrator" en:"In the moment there are no XMail administrators configured. If you want to create the standard administrator") <b>admin</b> $(lang de:"anlegen wollen, m&uuml;ssen Sie das Passwort f&uuml;r die freetz Konfigurations-Webseite neu setzten. Klicken Sie" en:"now, than you must set the password for the freetz web configuration interface again. Click") <b><a style='font-size:14px;' href=/cgi-bin/passwd.cgi>$(lang de:"hier" en:"here")</a></b> $(lang de:"um das Passwort jetzt neu zu setzen." en:"to set the password now.")</p>
EOF
sec_end

sec_begin "$(lang de:"Server Logging" en:"Server logging")"
cat << EOF
<p style="font-size:10px;">$(lang de:"Bitte beachte, dass XMail die Logdaten in logs/ speichert." en:"Please note that XMail saves the log data in logs/.")</p>
<p>
<input type="hidden" name="smtplog" value="no">
<input id="l1" type="checkbox" name="smtplog" value="yes"$smtplog_chk><label for="l1"> $(lang de:"SMTP Log aktivieren" en:"Activate SMTP logging")</label>
</p>
<p>
<input type="hidden" name="pop3log" value="no">
<input id="l2" type="checkbox" name="pop3log" value="yes"$pop3log_chk><label for="l2"> $(lang de:"POP3 Log aktivieren" en:"Activate POP3 logging")</label>
</p>
<p>
<input type="hidden" name="systemlog" value="no">
<input id="l3" type="checkbox" name="systemlog" value="yes"$systemlog_chk><label for="l2"> $(lang de:"XMail-internes Log aktivieren" en:"Activate XMail internal logging")</label>
</p>
EOF
sec_end

[ "$XMAIL_SSLSUPPORT" == 1 -o "$XMAIL_PHPXMAIL" != 1 ] && (
sec_begin "$(lang de:"Tipps zur Konfiguration" en:"Hints for configuration")"
[ "$XMAIL_SSLSUPPORT" == 1 ] &&
cat << EOF
<p style="font-size:10px;">$(lang de:"Zur Aktivierung von SSL musst du das SSL Zertifikat und den entsprechenden privaten SSL Schl&uuml;ssel in das oben angegebene Verzeichnis f&uuml;r XMail kopieren: Das Zertifikat muss als Datei server.cert und der private Schl&uuml;ssen als Datei server.key gespeichert werden. Beachte bitte, dass XMail das Recht haben muss, diese Dateien zu lesen (wenn du oben ausgew&auml;hlt hast, dass XMail mit einer unpriviligierten Benutzer-ID startet, m&uuml;ssen die Dateien lesbar f&uuml;r den Benutzer xmail oder die Gruppe xmail sein)." en:"To activate SSL you have to provide the SSL certificate and the corresponding private key which have to be copied into the above given XMail directory. The certificate must be saved in the file server.cert and the key in the file server.key. Please ensure that XMail has the permissions to read those files (if you selected to start XMail with an unprivileged ID, these files must be readable by the user xmail or group xmail).")</p>
<hr>
EOF
[ "$XMAIL_PHPXMAIL" != 1 ] &&
cat << EOF
<p style="font-size:10px;">$(lang de:"F&uuml;r XMail existiert ein PHP Webfrontend, welches alle Konfigurationsparameter, die Administration von Email-Domains und Benutzern beherrscht: <a href=http://phpxmail.sourceforge.net>PHPXmail</a>. Um dieses Frontend auf der Fritz!Box zu verwenden, musst du folgende Schritte durchf&uuml;hren:<br/>1. Installiere XMail (wenn du diese Seite liest, dann hast du diesen Punkt bereits geschafft).<br/>2. Aktiviere im XMail Freetz-Webfrontend den unverschl&uuml;sselten Admin-Zugang.<br/>3. In der crtlaccounts.tab XMail Konfigurationsdatei einen Account eintragen (siehe XMail readme.txt).<br/>4. Installiere PHP und lighttpd (es muss mod_fastcgi f&uuml;r lighttpd gew&auml;hlt werden, damit PHP funktioniert).<br/>5. Konfiguriere lighttpd und aktiviere PHP mittels dem Freetz-Webfrontend.<br/>6. Kopiere den Inhalt des PHPXmail Zip-Archivs in ein Verzeichnis innerhalb des lighttpd Dokumentenverzeichnisses.<br/>7. Starte einen Webbrowser und lade die URL deines lighttpd Servers, Verzeichnis des PHPXmail Frontends.<br/>8. Trage im erscheinenden Webfrontend im Namen localhost, als IP \"127.0.0.1\", und im Benutzernamen- und Passwordfeld die Benutzerdaten ein, welche du f&uuml;r die ctrlaccounts.tab Datei verwendet hast und best&auml;tige diese Konfiguration.<br/>9. Nun klicke auf login im PHPXmail Webfrontend und Benutze die gleichen Benutzerdaten wieder.<br/>10. Zugang zu allen XMail Konfigurationsparametern ist nun m&ouml;glich - es ist kein Neustart von XMail nach &Auml;nderungen notwendig." en:"TBD - see German part")</p>
EOF
sec_end
)
