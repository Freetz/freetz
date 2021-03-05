#!/bin/sh

. /usr/lib/libmodcgi.sh

cgi --id=backup_restore
cgi_begin "$(lang de:"Konfiguration sichern/wiederherstellen" en:"Backup/restore configuration")"
[ -x "$(which openssl)" ] && OPENSSL_FOUND=y || OPENSSL_FOUND=n

cat << EOF
<h1>$(lang de:"Sicherung" en:"Backup")</h1>

<p>$(lang \
  de:"Sichern s&auml;mtlicher Einstellungen aus dem Flash-Speicher <i>/var/flash</i>. Dies umfa&szlig;t sowohl die Einstellungen der Original-Firmware als auch die von Freetz sowie s&auml;mtlicher sonstiger beim Start geladener Erweiterungen (z.B. LCR-Updater)." \
  en:"Save all settings from flash memory <i>/var/flash</i>. This includes original firmware settings as well as Freetz and other installed extensions (e.g. LCR Updater)." \
)</p>

<h2>$(lang de:"Verschl&uuml;sselung" en:"Encryption")</h2>
<p>
EOF

if [ "$OPENSSL_FOUND" == "n" ]; then
	echo "$(lang de:"Es ist kein OpenSSL installiert. Verschl&uuml;sselung nicht verf&uuml;gbar" en:"There is no OpenSSL installed. Encryption not available")!<br>"
fi

cat << EOF
$(lang \
  de:"Ein verschl&uuml;sseltes Backup enth&auml;lt zus&auml;tzliche Daten um die Sicherung auch auf einem anderen Ger&auml;t wiederherzustellen zu k&ouml;nnen." \
  en:"An encrypted backup contains additional data to restore the backup even on another device." \
)
</p>

<form action="do_backup.cgi" method="GET">
EOF

if [ "$OPENSSL_FOUND" == "y" ]; then
	echo "<p><label for="password_restore">$(lang de:"Passwort (leer lassen f&uuml;r unverschl&uuml;sselt)" en:"Password (leave empty for unencrypted)"):<br></label>"
	echo "<input type=text name="password_restore" id="password_restore" size="35"></p>"
fi

cat << EOF
	<p><input type=submit value="$(lang de:"Sichern" en:"Save")" style="width:150px"></p>
</form>

<hr>
<h1>$(lang de:"Wiederherstellung" en:"Restore")</h1>

<p>$(lang \
  de:"Wiederherstellen eines zuvor gesicherten Archivs mit Einstellungen. Damit wird das Ger&auml;t wieder in den Zustand zum Zeitpunkt der entsprechenden Sicherung versetzt." \
  en:"Restore previously saved configuration archive.  This way the device will be restored to the state it was in when you created the corresponding backup." \
)</p>

<p><b><i>$(lang \
  de:"Nach der Wiederherstellung sollte das Ger&auml;t neu gestartet werden, um alle Einstellungen zu aktivieren. Bitte danach die Einstellungen &uuml;berpr&uuml;fen!" \
  en:"After restore you should reboot the device in order to activate the configuration. Please remember to double-check all settings afterwards!" \
)</i></b></p>

<form action="do_restore.cgi" method="POST" enctype="multipart/form-data">
	<p><input type=file name="uploadfile"></p>
	<p>
	  <input type=checkbox name="freetz_only" id="freetz_only"><label for="freetz_only">$(lang de:"Nur Freetz-Einstellungen wiederherstellen" en:"Restore Freetz settings only")</label><br>
	  <input type=checkbox name="restart" id="restart" checked><label for="restart">$(lang de:"Neustart nach Wiederherstellung" en:"Reboot after restore")</label>
	</p>
EOF

if [ "$OPENSSL_FOUND" == "y" ]; then
	echo "<p><label for="password_restore">$(lang de:"Passwort (falls verschl&uuml;sselt)" en:"Password (if encrypted)"):<br>"
	echo "</label><input type=password name="password_restore" id="password_restore" size="35"></p>"
fi

cat << EOF
	<p><input type=submit value="$(lang de:"Wiederherstellen" en:"Restore")" style="width:150px"></p>
</form>
EOF

cgi_end

