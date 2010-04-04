#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi_begin '$(lang de:"Konfiguration sichern/wiederherstellen" en:"Backup/restore configuration")' 'backup_restore'

cat << EOF
<h1>$(lang de:"Sicherung" en:"Backup")</h1>

<p>$(lang 
    de:"Sichern sämtlicher Einstellungen aus dem Flash-Speicher
<i>/var/flash</i>. Dies umfaßt sowohl die Einstellungen der Original-Firmware
als auch die von Freetz sowie sämtlicher sonstiger beim Start geladener
Erweiterungen (z.B. LCR-Updater)."
    en:"Save all settings from flash memory <i>/var/flash</i>. This includes
original firmware settings as well as Freetz and other installed extensions
(e.g. LCR Updater)."
)</p>

<form action="/cgi-bin/do_backup.cgi" method="GET">
	<p><input type=submit value="$(lang de:"Sichern" en:"Save")"></p>
</form>

<h1>$(lang de:"Wiederherstellung" en:"Restore")</h1>

<p>$(lang
    de:"Wiederherstellen eines zuvor gesicherten Archivs mit Einstellungen.
Damit wird die Fritz!Box wieder in den Zustand zum Zeitpunkt der entsprechenden
Sicherung versetzt."
    en:"Restore previously saved configuration archive.  This way the Fritz!Box
will be restored to the state it was in when you created the corresponding
backup."
)</p>

<p><b><i>$(lang
    de:"Nach der Wiederherstellung sollte das Gerät neu gestartet werden, um
alle Einstellungen zu aktivieren. Bitte danach die Einstellungen überprüfen!"
    en:"After restore you should reboot the device in order to activate the
configuration. Please remember to double-check all settings afterwards!"
)</i></b></p>

<form action="/cgi-bin/do_restore.cgi" method="POST" enctype="multipart/form-data">
	<p><input type=file name="uploadfile"></p>
	<p><input type=checkbox name="freetz_only">$(lang de:"Nur Freetz-Einstellungen wiederherstellen" en:"Restore Freetz settings only")<br>
	<input type=checkbox name="restart" checked>$(lang de:"Neustart nach Wiederherstellung" en:"Reboot after restore")</p>
	<p><input type=submit value="$(lang de:"Wiederherstellen" en:"Restore")" style="width:150px"></p>
</form>
EOF

cgi_end
