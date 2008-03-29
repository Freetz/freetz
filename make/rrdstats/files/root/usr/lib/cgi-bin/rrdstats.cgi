#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''

if [ "$RRDSTATS_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1">Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2">Manuell</label>
</p>
EOF

sec_end
sec_begin 'Anzeigen'
cat << EOF
<ul>
<li><a href="/cgi-bin/pkgstatus.cgi?pkg=rrdstats&cgi=rrdstats/stats">Statistiken anzeigen</a></li>
EOF

sec_end
sec_begin 'Einstellungen'

cat << EOF
<p>Tempor&auml;res Verzeichnis:&nbsp;<input type="text" name="rrdtemp" size="45" maxlength="255" value="$(httpd -e "$RRDSTATS_RRDTEMP")"></p>
<p>Persistentes Verzeichnis:&nbsp;<input type="text" name="rrddata" size="45" maxlength="255" value="$(httpd -e "$RRDSTATS_RRDDATA")"></p>
<p>Interface f&uuml;r Sammlung:&nbsp;&nbsp;&nbsp;<input type="text" name="waninterface" size="20" maxlength="99" value="$(httpd -e "$RRDSTATS_WANINTERFACE")">
<br><FONT SIZE=-2>Beispiele:&nbsp;cpmac0 (DSL-Modem), wan (ATA-Modus), lan (Netzwerk)</FONT></p>
<p>Intervall in Sekunden:&nbsp;<input type="text" name="interval" size="3" maxlength="9" value="$(httpd -e "$RRDSTATS_INTERVAL")"></p>
<p>Optionen f&uuml;r Netzwerk:&nbsp;<input type="text" name="net_advance" size="40" maxlength="255" value="$(httpd -e "$RRDSTATS_NET_ADVANCE")">
<br><FONT SIZE=-2>Beispiele:&nbsp;-l 0 (default), -o (logarithmisch)</FONT></p>
EOF

sec_end
