#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$OPENDD_ENABLED" yes:auto "*":man
check "$OPENDD_FORCE_UPDATE" yes:force_update
check "$OPENDD_WILDCARD" 1:wildcard
check "$OPENDD_BACKUPMX" 1:backupmx
check "$OPENDD_OFFLINE" 1:offline
check "$OPENDD_USE_SSL" 1:use_ssl
check "$OPENDD_EMAIL_ENABLED" yes:email_enabled

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="auto" type="radio" name="enabled" value="yes"$auto_chk><label for="auto"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="manual" type="radio" name="enabled" value="no"$man_chk><label for="manual"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<font size="1">
$(lang de:"OpenDD aktualisiert die dynamischen DNS-Adressen nach einem IP-Wechsel automatisch und l&auml;uft nicht als Dienst." en:"OpenDD updates the dynamic dns addresses automatically after an IP change and doesn't need to run as a daemon.")
</font>
EOF
sec_end

sec_begin '$(lang de:"Optionen" en:"Options")'
cat << EOF
<p>
<input type="hidden" name="force_update" value="no">
<input id="u1" type="checkbox" name="force_update" value="yes"$force_update_chk><label for="u1">$(lang de:"Sp&auml;testens nach 25 Tagen updaten (hierf&uuml;r sollte crond noch aktiviert sein)." en:"Force update after 25 days (you should also enable crond).")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Account" en:"Account")'
cat << EOF
<p>$(lang de:"Server" en:"Server"): <input type="text" name="server" size="55" maxlength="250" value="$(html "$OPENDD_SERVER")"></p>
<p>$(lang de:"Hostname" en:"Hostname"): <input type="text" name="host" size="55" maxlength="250" value="$(html "$OPENDD_HOST")">
<br><font size=-2>$(lang de:"Mehrere mit Komme getrennt angeben" en:"Use comma to enter more than one").</font>
</p>
<p>$(lang de:"Benutzername" en:"Username"): <input type="text" name="user" size="55" maxlength="250" value="$(html "$OPENDD_USER")"></p>
<p>$(lang de:"Passwort" en:"Password"): <input type="password" name="pass" size="55" maxlength="250" value="$(html "$OPENDD_PASS")"></p>
<p>
<input type="hidden" name="use_ssl" value="0">
<input id="o1" type="checkbox" name="use_ssl" value="1"$use_ssl_chk><label for="o1"> $(lang de:"SSL nutzen (h&auml;ngt von der Binary ab)" en:"Use SSL (depends on your binary)")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"E-Mail" en:"E-Mail")'
cat << EOF
<p>
<input type="hidden" name="email_enabled" value="no">
<input id="e1" type="checkbox" name="email_enabled" value="yes"$email_enabled_chk><label for="e1"> $(lang de:"eMail verschicken" en:"Send eMail")</label>
</p>
<p>$(lang de:"Absender" en:"From"): <input type="text" name="email_from" size="55" maxlength="250" value="$(html "$OPENDD_EMAIL_FROM")"></p>
<p>$(lang de:"Empf&auml;nger" en:"To"): <input type="text" name="email_to" size="55" maxlength="250" value="$(html "$OPENDD_EMAIL_TO")"></p>
<p>$(lang de:"E-Mail-Server" en:"E-mail-server"): <input type="text" name="email_server" size="55" maxlength="250" value="$(html "$OPENDD_EMAIL_SERVER")"></p>
<p>$(lang de:"Benutzername" en:"Username"): <input type="text" name="email_user" size="55" maxlength="250" value="$(html "$OPENDD_EMAIL_USER")"></p>
<p>$(lang de:"Passwort" en:"Password"): <input type="password" name="email_pass" size="55" maxlength="250" value="$(html "$OPENDD_EMAIL_PASS")"></p>
EOF
sec_end

sec_begin '$(lang de:"Erweiterte Optionen" en:"Advanced options")'
cat << EOF
<p>
<input type="hidden" name="wildcard" value="0">
<input id="a1" type="checkbox" name="wildcard" value="1"$wildcard_chk><label for="a1"> $(lang de:"Platzhalter" en:"Wildcard")</label>
</p>
<p>$(lang de:"Mailserver-Server" en:"Mailserver-Server"): <input type="text" name="mx" size="55" maxlength="250" value="$(html "$OPENDD_MX")"></p>
<p>
<input type="hidden" name="backupmx" value="0">
<input id="a2" type="checkbox" name="backupmx" value="1"$backupmx_chk><label for="a2"> $(lang de:"Host als Backup-Mailserver eintragen" en:"Use host as a backup mailserver")</label>
</p>
<p>
<input type="hidden" name="offline" value="0">
<input id="a3" type="checkbox" name="offline" value="1"$offline_chk><label for="a3"> $(lang de:"Offline-Host" en:"Offline-Host")</label>
</p>
EOF
sec_end


