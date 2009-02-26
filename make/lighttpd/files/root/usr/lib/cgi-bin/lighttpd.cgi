#!/bin/sh

PATH=/var/mod/bin:/var/mod/usr/bin:/var/mod/sbin:/var/mod/usr/sbin:/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''; dirlista_chk=''; dirlistd_chk=''; sslenaba_chk=''; sslenabd_chk=''; log_chk=''; modcgi_chk=''; modcompress_chk=''; error_chk=''; auth_chk=''; authbasic_chk=''; authdigest_chk=''; modstatus_chk=''; modstatussort_chk=''; chrooten_chk=''; chrootdi_chk=''; modfastcgiphp_chk=''; modfastcgiruby_chk=''

case "$LIGHTTPD_ENABLED" in yes) auto_chk=' checked';; *) man_chk=' checked';;esac
case "$LIGHTTPD_CHROOT" in yes) chrooten_chk=' checked';; *) chrootdi_chk=' checked';;esac
case "$LIGHTTPD_DIRLISTING" in enable) dirlista_chk=' checked';; *) dirlistd_chk=' checked';;esac
case "$LIGHTTPD_SSLENABLE" in enable) sslenaba_chk=' checked';; *) sslenabd_chk=' checked';;esac
if [ "$LIGHTTPD_LOGGING" = "yes" ]; then log_chk=' checked'; fi
if [ "$LIGHTTPD_MODCGI" = "yes" ]; then modcgi_chk=' checked'; fi
if [ "$LIGHTTPD_MODFASTCGIPHP" = "yes" ]; then modfastcgiphp_chk=' checked'; fi
if [ "$LIGHTTPD_MODFASTCGIRUBY" = "yes" ]; then modfastcgiruby_chk=' checked'; fi
if [ "$LIGHTTPD_MODCOMPRESS" = "yes" ]; then modcompress_chk=' checked'; fi
if [ "$LIGHTTPD_ERROR" = "yes" ]; then error_chk=' checked'; fi
if [ "$LIGHTTPD_AUTH" = "yes" ]; then auth_chk=' checked'; fi
if [ "$LIGHTTPD_MODSTATUS" = "yes" ]; then modstatus_chk=' checked'; fi
if [ "$LIGHTTPD_MODSTATUSSORT" = "enable" ]; then modstatussort_chk=' checked'; fi
case "$LIGHTTPD_AUTHMETH" in basic) authbasic_chk=' checked';; digest) authdigest_chk=' checked';;esac

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Web Server" en:"Web server")'
cat << EOF
<p> $(lang de:"Server binden an Port" en:"Listen on port"): <input type="text" name="port" size="5" maxlength="5" value="$(html "$LIGHTTPD_PORT")"></p>
EOF

cat << EOF
<p> $(lang de:"Verzeichnis der Daten" en:"Document Root"): <input type="text" name="docroot" size="30" maxlength="255" value="$(html "$LIGHTTPD_DOCROOT")"></p>
<p>$(lang de:"Soll das angegebe Datenverzeichnis auch als chroot-Verzeichnis genutzt werden?" en:"Shall the document root directory used as chroot directory?")</p>
<p>
<input id="c1" type="radio" name="chroot" value="yes"$chrooten_chk><label for="c1"> $(lang de:"Chroot nutzen" en:"Use chroot")</label>
<input id="c2" type="radio" name="chroot" value="no"$chrootdi_chk><label for="c2"> $(lang de:"Ohne chroot" en:"No chroot")</label>
</p>
EOF
sec_end

if [ -f /usr/lib/mod_dirlisting.so ]; then
sec_begin '$(lang de:"Erlaube Auflistung des Verzeichnisinhalts" en:"Allow listing of directory contents")'
cat << EOF
<p>
<input id="d1" type="radio" name="dirlisting" value="enable"$dirlista_chk><label for="d1"> $(lang de:"Aktiviert" en:"Activated")</label>
<input id="d2" type="radio" name="dirlisting" value="disable"$dirlistd_chk><label for="e2"> $(lang de:"Deaktiviert" en:"Deactivate")</label>
</p>
EOF

cat << EOF
<p> $(lang de:"Kodierung der Dateinamen" en:"File name encoding"): <input type="text" name="dirlistingenc" size="6" maxlength="10" value="$(html "$LIGHTTPD_DIRLISTINGENC")"></p>
EOF
sec_end
fi

if strings /usr/bin/lighttpd | grep -q "+ SSL Support"; then
sec_begin '$(lang de:"SSL Unterst&uuml;tzung" en:"SSL support")'
cat << EOF
<p style="font-size:10px;">$(lang de:"Damit lighttpd mit SSL-Unterst&uuml;tzung gestartet werden kann, m&uuml;ssen Zertifikat &amp; Schl&uuml;ssel <a href=\"/cgi-bin/file.cgi?id=lighttpd_crt\">hier</a> eingetragen sein." en:"To start lighttpd with SSL-Support you have to setup Certifikat&amp;Key <a TARGET=\"_blank\" href=\"/cgi-bin/file.cgi?id=lighttpd_crt\">here</a>.")</p>
<p style="font-size:10px;">$(lang de:"Falls das Zertifikat mit einer CA signiert wurde, tragen Sie bitte das CA Zertifikat <a href=\"/cgi-bin/file.cgi?id=lighttpd_ca\">hier</a> ein." en:"In case the certificate was signed with a CA, please provide the CA certificate <a TARGET=\"_blank\" href=\"/cgi-bin/file.cgi?id=lighttpd_ca\">here</a>.")</p>
<p style="font-size:10px;">$(lang de:"Bitte beachten Sie, dass der Port entsprechend konfiguriert werden sollte (HTTPS: 443)" en:"Please consider also to configure the appropriate port (HTTPS: 443)")</p>
<input id="d1" type="radio" name="sslenable" value="enable"$sslenaba_chk><label for="d1"> $(lang de:"Aktiviert" en:"Activated")</label>
<input id="d2" type="radio" name="sslenable" value="disable"$sslenabd_chk><label for="e2"> $(lang de:"Deaktiviert" en:"Deactivate")</label>
</p>
EOF
sec_end
fi

if [ -f /usr/lib/mod_auth.so ]; then
sec_begin '$(lang de:"Zugriffskontrolle" en:"Access control")'
cat << EOF
<p style="font-size:10px;">$(lang de:"Damit lighttpd Benutzer authentisieren kann, m&uuml;ssen Benutzer <a href=\"/cgi-bin/file.cgi?id=lighttpd_user\">hier</a> eingetragen sein." en:"To allow lighttpd to authenticate users, you have to add users <a TARGET=\"_blank\" href=\"/cgi-bin/file.cgi?id=lighttpd_user\">here</a>.")</p>
<p style="font-size:10px;">$(lang de:"Zugriffsrechte k&ouml;nnen <a href=\"/cgi-bin/file.cgi?id=lighttpd_rights\">hier</a> eingetragen werden." en:"Access rights can be added <a href=\"/cgi-bin/file.cgi?id=lighttpd_rights\">here</a>.")</p>
<p><input type="hidden" name="auth" value="no">
<input id="z1" type="checkbox" name="auth" value="yes"$auth_chk><label for="z1"> $(lang de:"Zugriffskontrolle und Benutzerkonten aktivieren" en:"Activate access control and user accounts")</label></p>
<p>
<input id="z2" type="radio" name="authmeth" value="basic"$authbasic_chk><label for="z2"> $(lang de:"Basic Authentisierung" en:"Basic authentication")</label>
<input id="z3" type="radio" name="authmeth" value="digest"$authdigest_chk><label for="z3"> $(lang de:"Digest Authentisierung" en:"Digest Authentication")</label>
EOF
sec_end
fi

sec_begin '$(lang de:"Erweiterte Einstellungen" en:"Advanced Options")'
if [ -f /usr/lib/mod_cgi.so ]; then
cat << EOF
<p><input type="hidden" name="modcgi" value="no">
<input id="b1" type="checkbox" name="modcgi" value="yes"$modcgi_chk><label for="b1"> $(lang de:"mod_cgi aktivieren (Dateien *.cgi und in /cgi-bin ausf&uuml;hrbar)" en:"Activate mod_cgi (files *.cgi and in /cgi-bin executable")</label></p>
<br />
EOF
fi
if [ -f /usr/lib/mod_fastcgi.so ]; then
cat << EOF
<p><input type="hidden" name="modfastcgiphp" value="no">
<input id="b6" type="checkbox" name="modfastcgiphp" value="yes"$modfastcgiphp_chk><label for="b6"> $(lang de:"mod_fastcgi f&uuml;r PHP aktivieren (Dateien *.php ausf&uuml;hrbar)" en:"Activate mod_fastcgi for PHP (files *.php executable)")</label></p>
EOF
	foundphp=`which php-cgi`
	if [ ! -x "$foundphp" ]; then
		foundphp=""
cat << EOF
<p style="font-size:10px;">$(lang de:"Programm php-cgi wurde nicht gefunden. Bitte geben Sie den vollst&auml;ndigen Pfad zu diesem Programm in folgender Box an." en:"Program php-cgi was not found. Please provide complete path to this program.")</p>
EOF
	else
cat << EOF
<p style="font-size:10px;">$(lang de:"Programm php-cgi wurde im Pfad $foundphp gefunden. Bitte geben Sie diesen oder den entsprechenden vollst&auml;ndigen Pfad zu diesem Programm in folgender Box an." en:"Program php-cgi was found at $foundphp. Please either provide this or the correct path to this program in following box.")</p>
EOF
	fi
	if [ "x$LIGHTTPD_MODFASTCGIPHPPATH" = "x" ]; then LIGHTTPD_MODFASTCGIPHPPATH=$foundphp; fi
cat << EOF
<p> $(lang de:"Pfad zu php-cgi" en:"Path to php-cgi"): <input type="text" name="modfastcgiphppath" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODFASTCGIPHPPATH")"></p>
<p> $(lang de:"Maximale Anzahl der PHP Prozesse" en:"Maximum number of PHP processes"): <input type="text" name="modfastcgiphpmaxproc" size="2" maxlength="2" value="$(html "$LIGHTTPD_MODFASTCGIPHPMAXPROC")"></p>
<br />
<p><input type="hidden" name="modfastcgiruby" value="no">
<input id="b8" type="checkbox" name="modfastcgiruby" value="yes"$modfastcgiruby_chk><label for="b8"> $(lang de:"mod_fastcgi f&uuml;r RUBY aktivieren (Dateien *.rb ausf&uuml;hrbar)" en:"Activate mod_fastcgi for RUBY (files *.rb executable)")</label></p>
EOF
	foundruby=`which ruby-cgi`
	if [ ! -x "$foundruby" ]; then
		foundruby=""
cat << EOF
<p style="font-size:10px;">$(lang de:"Programm ruby-cgi wurde nicht gefunden. Bitte geben Sie den vollst&auml;ndigen Pfad zu diesem Programm in folgender Box an." en:"Program ruby-cgi was not found. Please provide complete path to this program.")</p>
EOF
	else
cat << EOF
<p style="font-size:10px;">$(lang de:"Programm ruby-cgi wurde im Pfad $foundruby gefunden. Bitte geben Sie diesen oder den entsprechenden vollst&auml;ndigen Pfad zu diesem Programm in folgender Box an." en:"Program ruby-cgi was found at $foundruby. Please either provide this or the correct path to this program in following box.")</p>
EOF
	fi
	if [ "x$LIGHTTPD_MODFASTCGIRUBYPATH" = "x" ]; then LIGHTTPD_MODFASTCGIRUBYPATH=$foundruby; fi
cat << EOF
<p> $(lang de:"Pfad zu ruby-cgi" en:"Path to ruby-cgi"): <input type="text" name="modfastcgirubypath" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODFASTCGIRUBYPATH")"></p>
<p> $(lang de:"Maximale Anzahl der RUBY Prozesse" en:"Maximum number of RUBY processes"): <input type="text" name="modfastcgirubymaxproc" size="2" maxlength="2" value="$(html "$LIGHTTPD_MODFASTCGIRUBYMAXPROC")"></p>
<br />
EOF
fi

if [ -f /usr/lib/mod_compress.so ]; then
cat << EOF
<p><input type="hidden" name="modcompress" value="no">
<input id="b2" type="checkbox" name="modcompress" value="yes"$modcompress_chk><label for="b2"> $(lang de:"mod_compress aktivieren (Cache Verzeichnis muss konfiguriert werden)" en:"Activate mod_compress (Cache dir must be configured")</label></p>
<p> $(lang de:"Verzeichnis der Cache Daten" en:"Directory of Cache"): <input type="text" name="modcompressdir" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODCOMPRESSDIR")"></p>
<br />
EOF
fi
if [ -f /usr/lib/mod_status.so ]; then
cat << EOF
<p><input type="hidden" name="modstatus" value="no">
<input id="b3" type="checkbox" name="modstatus" value="yes"$modstatus_chk><label for="b3"> $(lang de:"Statusanzeige aktivieren (URLs m&uuml;ssen konfiguriert werden)" en:"Activate status display (URLs must be configured")</label></p>
<p><input type="hidden" name="modstatussort" value="disable">
<input id="b4" type="checkbox" name="modstatussort" value="enable"$modstatussort_chk><label for="b4"> $(lang de:"JavaScript zum Sortieren der Statusanzeige aktivieren" en:"Activate JavaScript for sorting of status display")</label></p>
<p style="font-size:10px;">$(lang de:"Ein leeres URL Feld deaktiviert die jeweilige Statusanzeige." en:"An empty URL field deactivates the corresponding status display.")</p>
<p style="font-size:10px;">$(lang de:"Falls der Webserver im Internet erreichbar ist, sollten diese URLs gesch&uuml;tzt werden (zum Beispiel mit Zugriffskontrolle - siehe oben)." en:"In case the web server is reachable in the Internet, please consider the protection of these URLs (for example by using the access control feature - see above).")</p>
<p> $(lang de:"URL f&uuml;r Konfiguration" en:"URL for configuration"): <input type="text" name="modstatusconfig" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODSTATUSCONFIG")"></p>
<p> $(lang de:"URL f&uuml;r Statistiken" en:"URL for statistics"): <input type="text" name="modstatusstatistic" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODSTATUSSTATISTIC")"></p>
<p> $(lang de:"URL f&uuml;r Status" en:"URL for status"): <input type="text" name="modstatusstatus" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODSTATUSSTATUS")"></p>
<br />
EOF
fi
cat << EOF
<p><input type="hidden" name="error" value="no">
<input id="b5" type="checkbox" name="error" value="yes"$error_chk><label for="b5"> $(lang de:"Eigene Fehlermeldungen anstelle der automatischen Fehlermeldung aktivieren (Dateiprefix angeben)" en:"Return own error message instead of the automated error messages (provide file prefix")</label></p>
<p style="font-size:10px;">$(lang de:"Sie k&ouml;nnen den Server selbst-erstellte Fehlermeldungen zur&uuml;cksenden lassen, inklusive eigene 404 Fehlerseiten. Generell k&ouml;nnen auch andere HTTP-Fehler (zum Beispiel 500) entsprechend behandelt werden. Es k&ouml;nnen ausschliesslich statische Seiten zur&uuml;ckgesendet werden. Das Format der Dateinamen lautet: &lt;Fehlerdatei-Prefix&gt;&lt;status-code&gt;.html. Der Prefix muss dabei der absolute Pfadname auf dem Hostsystem sein, nicht nur innerhalb des Datenverzeichnisses." en:"You can customize what page to send back based on a status code. This provides you with an alternative way to customize 404 pages. You may also customize other status-codes with their own custom page (500 pages, etc). Only static files are allowed to be sent back. Format: &lt;errorfile-prefix&gt;&lt;status-code&gt;.html. This path must be the absolute path name on the host system, not only starting with the docroot.")</p>
<p> $(lang de:"Datei-Prefix f&uuml;r Fehler" en:"File prefix for error"): <input type="text" name="errorfile" size="30" maxlength="255" value="$(html "$LIGHTTPD_ERRORFILE")"></p>
<br />
<p style="font-size:10px;">$(lang de:"Die folgenden Boxen erlauben die maximale Datentransferrate in kBytes/s festzulegen. Der Wert 0 bedeutet kein Limit. Bitte beachten Sie, dass ein Wert von unter 32 kb/s effektiv den Verkehr auf 32 kb/s aufgrund der Gr&ouml;sse der TCP Sendepuffer drosselt." en:"The following boxes allw the specification of the maximum data transfer rate in kBytes/s. The value of 0 means no limit. Please note  that a limit below 32kb/s might actually limit the traffic to 32kb/s. This is caused by the size of the TCP send buffer.")</p>
<p> $(lang de:"Maximale Datenrate pro Verbindung" en:"Maximum throughput per connection"): <input type="text" name="limitconn" size="5" maxlength="5" value="$(html "$LIGHTTPD_LIMITCONN")"> kBytes/s</p>
<p> $(lang de:"Maximale Datenrate aller Verbindungen" en:"Maximum throughput for all connections"): <input type="text" name="limitsrv" size="5" maxlength="5" value="$(html "$LIGHTTPD_LIMITSRV")"> kBytes/s</p>

EOF
sec_end

sec_begin '$(lang de:"Zus&auml;tzliche Konfigurationsoptionen (f&uuml;r Experten)" en:"Additional config options (for experts)")'

cat << EOF
<p style="font-size:10px;">$(lang de:"Zus&auml;tzliche Konfigurationsoptionen k&ouml;nnen <a href=\"/cgi-bin/file.cgi?id=lighttpd_add\">hier</a> eingetragen werden." en:"Additional configuration options can be added <a TARGET=\"_blank\" href=\"/cgi-bin/file.cgi?id=lighttpd_add\">here</a>.")</p>
EOF
sec_end

sec_begin '$(lang de:"Server Logdateien" en:"Server log files")'
cat << EOF
<p style="font-size:10px;">$(lang de:"Bitte beachten Sie, dass die Logdateien wertvollen RAM Speicher belegen. Nutzen Sie das Logging nur f&uuml;r Fehlersuche und schalten es f&uuml;r den normalen Betrieb ab." en:"Please note that the log files use precious RAM memory. Use logging only for debugging and disable it for regular operation.")</p>
<p style="font-size:10px;"><a href="/cgi-bin/pkgstatus.cgi?pkg=lighttpd&cgi=lighttpd/lighttpd-log">$(lang de:"Logdateien anzeigen" en:"Show logfiles")</a></p>
EOF

cat << EOF
<p>
<input type="hidden" name="logging" value="no">
<input id="a1" type="checkbox" name="logging" value="yes"$log_chk><label for="a1"> $(lang de:"Log aktivieren" en:"Activate logging")</label>
</p>
EOF
sec_end

