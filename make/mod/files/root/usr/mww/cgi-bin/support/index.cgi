#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --id=support_file
cgi_begin '$(lang de:"Supportdatei erstellen" en:"Create support file")'
cat << EOF

<p>$(lang
	de:"Es wird eine Datei mit Konfiguartions- und Logdateien zusammengepackt
 die eine Fehlersuche erm&ouml;glicht. Es werden Callmonitor-Rufnummern, DSL-Serial,
 MAC-, IPv4- sowie IPv6-Adressen entfernt. Es gibt aber keine Garantie dass dies
 fehlerfrei funktioniert. Deshalb bitte vor Ver&ouml;ffentlichung der Datei selbst
 prüfen ob irgendwelche pers&ouml;nlich Daten enthalten sind!"
	en:"A file with config- and logfiles is created to find errors. Confidential
 details like Callmonitor phonenumbers, DSL-serial, MAC-, IPv4- and IPv6-addresses
 will be removed. But please check the file before publishing it!"
)</p>

<form action="do_support.cgi" method="GET">
<p><input type=submit value="$(lang de:"anfordern" en:"request")" style="width:150px"></p>
</form>

EOF
cgi_end
