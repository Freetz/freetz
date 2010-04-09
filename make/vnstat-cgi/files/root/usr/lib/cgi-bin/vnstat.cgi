#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$VNSTAT_ENABLED" yes:auto "*":man
check "$VNSTAT_WEBENABLED" yes:webenabled
check "$VNSTAT_WEB_AUTH" yes:web_auth

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1">$(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2">$(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Anzeigen" en:"Show statistics")'

cat << EOF
<ul>
<li><a href="$(href status vnstat stats)">$(lang de:"Statistiken anzeigen" en:"Show statistics")</a></li>
EOF

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Settings")'

cat << EOF
<p>
<a href="$(href file vnstat conf)">$(lang de:"Zum Bearbeiten der vnstat.conf hier klicken." en:"To edit the vnstat.conf click here.")</a>
</p>
<p>
$(lang de:"Datenbankverzeichnis" en:"Databse directory"):&nbsp;
<input type="text" name="dbdir" size="42" maxlength="255" value="$(html "$VNSTAT_DBDIR")">
</p>
<p>
$(lang de:"Zu &uuml;berwachende Interfaces" en:"Interfaces for monitoring"):&nbsp;
<input type="text" name="interfaces" size="55" maxlength="255" value="$(html "$VNSTAT_INTERFACES")">
<br>
<font size=-2>
$(lang de:"Verf&uuml;gbare Interfaces" en:"Available interfaces")
:&nbsp;`ifconfig |grep "^\w"|sed 's/ .*//g'`
$(lang de:" - leer lassen f&uuml;r alle" en:" - leave empty for all")
</font>
</p>
EOF

sec_end
sec_begin '$(lang de:"Webserver" en:"Webserver")'

cat << EOF
<p>
<input type="hidden" name="webenabled" value="no">
<input id="w1" type="checkbox" name="webenabled" value="yes"$webenabled_chk><label for="w1"></label>
$(lang de:"Zus&auml;tzlichen Webserver aktiveren auf Port" en:"Activate additional webserver on port")&nbsp;
<input type="text" name="web_port" size="4" maxlength="5" value="$(html "$VNSTAT_WEB_PORT")">
</p>
EOF

if [ "$VNSTAT_WEBENABLED" = "yes" ]; then
cat << EOF
<p>
<input type="hidden" name="web_auth" value="no">
<input id="a1" type="checkbox" name="web_auth" value="yes"$web_auth_chk><label for="a1">$(lang de:"Authentifizierung" en:"Authentication").</label>
$(lang de:"Benutzer" en:"User"):
<input type="text" name="web_user" size="15" maxlength="15" value="$(html "$VNSTAT_WEB_USER")">
$(lang de:"Passwort" en:"Password"):
<input type="password" name="web_pass" size="15" maxlength="15" value="$(html "$VNSTAT_WEB_PASS")">
</p>
EOF
fi

sec_end

