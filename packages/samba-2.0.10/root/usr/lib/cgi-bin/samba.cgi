#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
share_chk=''; master_chk=''

if [ "$SAMBA_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$SAMBA_DEFAULT_SHARE" = "yes" ]; then share_chk=' checked'; fi
if [ "$SAMBA_MASTER" = "yes" ]; then master_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Settings")'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=lmhosts">$(lang de:"Lmhosts bearbeiten" en:"Edit lmhosts")</a></li>
<li><a href="/cgi-bin/file.cgi?id=shares">$(lang de:"Freigaben bearbeiten" en:"Edit shares")</a></li>
</ul>
<p>
<input type="hidden" name="default_share" value="no">
<input id="s1" type="checkbox" name="default_share" value="yes"$share_chk><label for="s1"> $(lang de:"Standard Freigabe" en:"Default share")</label>
</p>
EOF

sec_end
sec_begin 'Samba'

cat << EOF
<h2>$(lang de:"Netzwerk Schnittstellen" en:"Interfaces"):</h2>
<p>$(lang de:"z.B.: 192.168.178.1/255.255.255.0" en:"e.g. 192.168.178.1/255.255.255.0")<br>
<input type="text" name="interfaces" size="40" maxlength="255" value="$(httpd -e "$SAMBA_INTERFACES")"></p>
<h2>$(lang de:"Box Name" en:"Box name")</h2>
<p>$(lang de:"Netbios Name" en:"Netbios name"): <input type="text" name="netbios_name" size="20" maxlength="255" value="$(httpd -e "$SAMBA_NETBIOS_NAME")"></p>
<p>$(lang de:"Arbeitsgruppe" en:"Workgroup"): <input type="text" name="workgroup" size="20" maxlength="255" value="$(httpd -e "$SAMBA_WORKGROUP")"></p>
<p>$(lang de:"Beschreibung" en:"Server string"):<br><input type="text" name="server_string" size="40" maxlength="255" value="$(httpd -e "$SAMBA_SERVER_STRING")"></p>
<h2>Master</h2>
<p>$(lang de:"OS Level" en:"OS level"): <input type="text" name="os_level" size="5" maxlength="5" value="$(httpd -e "$SAMBA_OS_LEVEL")"></p>
<p>
<input type="hidden" name="master" value="no">
<input id="m1" type="checkbox" name="master" value="yes"$master_chk><label for="m1"> $(lang de:"Bevorzugter Master" en:"Preferred master")</label>
</p>
EOF

sec_end
