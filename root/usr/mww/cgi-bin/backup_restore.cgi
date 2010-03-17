#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi_begin '$(lang de:"Konfiguration sichern/wiederherstellen" en:"Backup/restore configuration")' 'backup_restore'

cat << EOF
<h1>$(lang de:"Sicherung (Backup)" en:"Backup")</h1>

$(lang de:"Sichern sämtlicher Einstellungen aus dem Flash-Speicher <i>/var/flash</i>. Dies" en:"Save all settings from flash memory <i>/var/flash</i>. This includes original")
$(lang de:"umfaßt sowohl die Einstellungen der Original-Firmware als auch die von" en:"firmware settings as well as Freetz and other installed extensions")
$(lang de:"Freetz sowie sämtlicher sonstiger beim Start geladener Erweiterungen" en:"(e.g. LCR Updater).")
$(lang de:"(z.B. LCR-Updater)." en:"")
<p>

<form action="/cgi-bin/do_backup.cgi" method=GET>
	<input type=submit value="$(lang de:"Sichern" en:"Save")">
</form><p>

<h1>$(lang de:"Wiederherstellung (Restore)" en:"Restore")</h1>

$(lang de:"Wiederherstellen eines zuvor gesicherten Archivs mit Einstellungen." en:"Restore previously saved configuration archive.")
$(lang de:"Damit wird die Fritz!Box wieder in den Zustand zum" en:"This way the Fritz!Box will be restored to the state it was in when you")
$(lang de:"Zeitpunkt der entsprechenden Sicherung versetzt." en:"created the corresponding backup.")
<p>

<b><i>$(lang de:"Nach der Wiederherstellung sollte das Gerät neu gestartet werden, um" en:"After restore you should reboot the device in order to activate the")
$(lang de:"alle Einstellungen zu aktivieren. Bitte danach die Einstellungen überprüfen!" en:"configuration. Please remember to double-check all settings afterwards!")</i></b>
<p>

<form action="/cgi-bin/do_restore.cgi" method=POST enctype="multipart/form-data">
	<input type=file name="uploadfile"><br>
	<input type=checkbox name="freetz_only">$(lang de:"Nur Freetz-Einstellungen wiederherstellen" en:"Restore Freetz settings only")<p>
	<input type=checkbox name="restart" checked>$(lang de:"Neustart nach Wiederherstellung" en:"Reboot after restore")<p>
	<input type=submit value="$(lang de:"Wiederherstellen" en:"Restore")" style="width:150px">
</form>
<form action="/cgi-bin/status.cgi" method=GET>
	<input type="submit" value="$(lang de:"Abbrechen" en:"Cancel")" style="width:150px">
</form>
EOF

cgi_end
