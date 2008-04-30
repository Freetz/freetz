#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
master_chk=''

if [ "$SAMBA_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$SAMBA_MASTER" = "yes" ]; then master_chk=' checked'; fi

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1">Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2">Manuell</label>
</p>
EOF

sec_end
sec_begin 'Einstellungen'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=shares">Eigene Freigaben</a></li>
<li><a href="/cgi-bin/file.cgi?id=sharesx">Experten Optionen</a></li>
</ul>
EOF
if [ -d /var/media/ftp ]; then
cat << EOF
<p>
<FONT SIZE=-1>Standard Freigabe(n) bitte im AVM WebIF festlegen:<br>Erweiterte Einstellungen > USB-Ger&auml;te > USB-Speicher</FONT><br><FONT SIZE=-2>Optionen: Netzwerkspeicher (an/aus) - Zugriffsberechtigung (rw/ro) - Kennwortschutz (ohne/setzen)</FONT>
</p>
EOF
fi

sec_end
sec_begin 'Samba'

cat << EOF
<br><P>Netzwerkschnittstelle:<br>
<input type="text" name="interfaces" size="40" maxlength="255" value="$(html "$SAMBA_INTERFACES")"><br>
<FONT SIZE=-2>z.B.: 192.168.178.1/255.255.255.0 oder leer lassen f&uuml;r alle</FONT></P>
<p>Netbios Name: <input type="text" name="netbios_name" size="20" maxlength="255" value="$(html "$SAMBA_NETBIOS_NAME")"></p>
<p>Arbeitsgruppe: <input type="text" name="workgroup" size="20" maxlength="255" value="$(html "$SAMBA_WORKGROUP")"></p>
<p>Beschreibung:<br><input type="text" name="server_string" size="40" maxlength="255" value="$(html "$SAMBA_SERVER_STRING")"></p>
<p>OS Level f&uuml;r Election: <input type="text" name="os_level" size="5" maxlength="5" value="$(html "$SAMBA_OS_LEVEL")"></p>
<p>
<input type="hidden" name="master" value="no">
<input id="m1" type="checkbox" name="master" value="yes"$master_chk><label for="m1">Bevorzugter Master</label>
</p>
EOF

sec_end
