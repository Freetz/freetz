#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi_begin 'Konfiguration sichern/wiederherstellen' 'backup_restore'

cat << EOF
<h1>Sicherung (Backup)</h1>

Sichern s‰mtlicher Einstellungen aus dem Flash-Speicher <i>/var/flash</i>. Dies
umfaﬂt sowohl die Einstellungen der Original-Firmware als auch die des
DS-Mod sowie s‰mtlicher sonstiger beim Start geladener Erweiterungen (z.B.
LCR-Updater).<p>

<form action="/cgi-bin/do_backup.cgi" method=GET>
  <input type=submit value="Sichern">
</form><p>

<h1>Wiederherstellung (Restore)</h1>

Wiederherstellen eines zuvor gesicherten Archivs mit Einstellungen
<i>(var_flash.tar.gz)</i>. Damit wird die Fritz!Box wieder in den Zustand zum
Zeitpunkt der entsprechenden Sicherung versetzt.<p>

<b><i>Nach der Wiederherstellung sollte das Ger‰t neu gestartet werden, um
alle Einstellungen zu aktivieren.</i></b><p>

<form action="/cgi-bin/do_restore.cgi" method=POST enctype="multipart/form-data">
  <input type=file name="uploadfile"><br>
  <input type=checkbox name="restart" checked>Neustart nach Wiederherstellung<p>
  <input type=submit value="Wiederherstellen">
</form>
EOF

cgi_end
