#!/bin/sh


. /usr/lib/libmodcgi.sh


sec_begin "$(lang de:"Information" en:"Information")"

cat << EOF
<p>
<font size='1'>
$(lang en:"When starting Mcabber just the configfile (/mod/root/.mcabberrc) is created." de:"Beim Starten von Mcabber wird nur die Configdatei(/mod/root/.mcabberrc) erstellt.")
<br>
$(lang en:"To start Mcabber you have to start it from the console." de:"Mcabber ist kein Daemon und kann nur von der Konsole gestartet werden.")
</font>
</p>
EOF

sec_end
sec_begin "$(lang de:"Einstellungen" en:"settings")"

cat << EOF
<p>$(lang de:"Benutzername" en:"username"): <input id="username" type="text" name="username" value="$(html "$MCABBER_USERNAME")"></p>
<p>$(lang de:"Server" en:"server"): <input id="server" type="text" name="server" value="$(html "$MCABBER_SERVER")"></p>
<h2>$(lang de:"Zus&auml;tzliche Einstellungen" en:"additional settings")</h2>
<font size='1'>
<p>$(lang de:"z.B. set proxy_host = \"proxy-hostname\"" en:"e.g. set proxy_host = \"proxy-hostname\"")</p>
<p>$(lang de:"Mehr Infos: <a TARGET=\"_blank\" href=\"http://www.lilotux.net/~mikael/mcabber/\">hier</a>" en:"more information: <a TARGET=\"_blank\" href=\"http://www.lilotux.net/~mikael/mcabber/\">here</a>")</font></p>
<p><textarea name="add_settings" rows="4" cols="50" maxlength="255">$(html "$MCABBER_ADD_SETTINGS")</textarea></p>
EOF

sec_end
