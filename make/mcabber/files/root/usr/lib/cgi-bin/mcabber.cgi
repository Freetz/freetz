#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$MCABBER_ENABLED" yes:auto "*":man


sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>$(lang de:"Starttyp" en:"Start type")<br />
<font size='1'>$(lang en:"When starting Mcabber-Config just the configfile (/var/mod/root/.mcabberrc) is created.<br /> To start Mcabber you have to start it from the console." de:"Beim starten von Mcabber-Config wird nur die Configdatei(/var/mod/root/.mcabberrc) erstellt. <br />Mcabber selber muss in der Konsole gestartet werden.")</font><br />
<input id="auto1" type="radio" name="enabled" value="yes"$auto_chk><label for="auto1">$(lang de:"Automatisch" en:"Automatic")</label>
<input id="auto2" type="radio" name="enabled" value="no"$man_chk><label for="auto2">$(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Einstellungen" en:"settings")'

cat << EOF
<p>$(lang de:"Benutzername" en:"username"): <input id="username" type="text" name="username" value="$(html "$MCABBER_USERNAME")">
<br />$(lang de:"Server" en:"server"): <input id="server" type="text" name="server" value="$(html "$MCABBER_SERVER")"></p>
<h2>$(lang de:"Zus&auml;tzliche Einstellungen" en:"additional settings")</h2>
<font size='1'>$(lang de:"z.B. set proxy_host = \"proxy-hostname\"" en:"e.g. set proxy_host = \"proxy-hostname\"")<br />
$(lang de:"Mehr Infos: <a TARGET=\"_blank\" href=\"http://www.lilotux.net/~mikael/mcabber/\">hier</a>" en:"more information: <a TARGET=\"_blank\" href=\"http://www.lilotux.net/~mikael/mcabber/\">here</a>")</font><br />
<p><textarea name="add_settings" rows="4" cols="50" maxlength="255">$(html "$MCABBER_ADD_SETTINGS")</textarea></p>
EOF

sec_end
