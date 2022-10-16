#!/bin/sh


. /usr/lib/libmodcgi.sh

check "$DEHYDRATED_ENABLED" yes:auto "*":man

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cat << EOF
<p>
<input id="auto" type="radio" name="enabled" value="yes"$auto_chk><label for="auto"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="manual" type="radio" name="enabled" value="no"$man_chk><label for="manual"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<font size="1">
$(lang de:"Let's Encrypt aktualisiert die Zertifikate mittels cron automatisch und l&auml;uft nicht als Dienst." en:"Let's Encrypt renews the certificates automatically by cron and doesn't need to run as a daemon.")</i>
</font>
EOF
sec_end

sec_begin "$(lang de:"Anzeigen" en:"Show")"
cat << EOF
<ul>
<li><a href="$(href status dehydrated dehydrated_log)">$(lang de:"Logdatei anzeigen" en:"Show log file")</a></li>
</ul>
EOF
sec_end

sec_begin "$(lang de:"Cron" en:"Cron")"
cat << EOF
<p><input type="text" name="crond_h" size="6" maxlength="9" value="$(html "$DEHYDRATED_CROND_H")">&nbsp;$(lang de:"Stunde" en:"Hour")</p>
<p><input type="text" name="crond_m" size="6" maxlength="9" value="$(html "$DEHYDRATED_CROND_M")">&nbsp;$(lang de:"Minute" en:"Minute")</p>
<p><input type="text" name="crond_d" size="6" maxlength="9" value="$(html "$DEHYDRATED_CROND_D")">&nbsp;$(lang de:"Tag" en:"Day")</p>
EOF
sec_end

sec_begin "$(lang de:"Optionen" en:"Options")"
cat << EOF

<p>$(lang de:"Schl&uuml;sselgr&ouml;&szlig;e (mindestens 2048)" en:"Key length (at least 2048)"): <input type="text" name="keysize" size="5" maxlength="4" value="$(html "$DEHYDRATED_KEYSIZE")"></p>

<p>$(lang de:"Speicherverzeichnis der Zertifikate" en:"Certificate storage directory"): <input type="text" name="certdir" size="55" maxlength="250" value="$(html "$DEHYDRATED_CERTDIR")">
<br><font size=-2>$(lang de:"Die privaten Schl&uuml;ssel zum einbinden in Lighttpd z.B. mit <i>ssl.pemfile</i> werden hier zu finden sein" en:"Private certificates to use with Lighttpd e.g. by <i>ssl.pemfile</i> will be placed here"):<br>${DEHYDRATED_CERTDIR%/*}/DOMAIN/ssl.pem </font>
</p>

<p>$(lang de:"Verzeichnis des Webservers" en:"Web server public directory"): <input type="text" name="webroot" size="55" maxlength="250" value="$(html "$DEHYDRATED_WEBROOT")">
<br><font size=-2>$(lang de:"Zum ver&ouml;ffentlichen von Dateien der acme-challenge via http." en:"To publish acme-challenge files by http.")</font>
</p>

<p>$(lang de:"Logdatei" en:"Log file"): <input type="text" name="logfile" size="55" maxlength="250" value="$(html "$DEHYDRATED_LOGFILE")"></p>
EOF
sec_end

sec_begin "$(lang de:"Erweitert" en:"Advanced")"
cat << EOF
<p>$(lang de:"E-Mail Adresse" en:"E-mail address"): <input type="text" name="regmail" size="55" maxlength="255" value="$(html "$DEHYDRATED_REGMAIL")"></p>
EOF

[ -r /etc/options.cfg ] && . /etc/options.cfg
if [ "$FREETZ_PACKAGE_LIGHTTPD" == "y" ]; then
	cgi_print_checkbox_p "cychttp" "$DEHYDRATED_CYCHTTP" "$(lang de:"Restarte Lighttpd nach Erneuerung" en:"Restart Lighttpd after renew")."
fi

cat << EOF
$(lang de:"Eigene Eintr&auml;ge in der" en:"Custom values into") <a target='_blank' href='https://github.com/lukas2511/dehydrated/blob/master/docs/examples/config'>config</a>:<p>
<textarea name="usercfg" rows="5" cols="75" maxlength="255">$(html "$DEHYDRATED_USERCFG")</textarea>
</p>
EOF
sec_end

sec_begin "$(lang de:"Hinweis" en:"Note")"
cat << EOF
<ul>
<li>$(lang de:"Zum initialisieren und anzeigen der Ausgaben" en:"To initialize and show output run"): <i>rc.dehydrated init</i></li>
</ul>
EOF
sec_end

