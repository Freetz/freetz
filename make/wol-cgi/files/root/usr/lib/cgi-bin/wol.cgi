#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$WOL_ENABLED" "" "" 1
sec_end

sec_begin "$(lang de:"Anzeigen" en:"Show")"

cat << EOF
<ul>
<li><a href="/cgi-bin/wol" target="_blank">$(lang de:"WOL-Webinterface" en:"WOL web interface")</a></li>
</ul>
EOF

sec_end

sec_begin "$(lang de:"Bekannte Hosts" en:"Known hosts")"

cat << EOF
<ul>
<li><a href="$(href file mod hosts)">$(lang de:"Hosts bearbeiten" en:"Edit hosts")</a></li>
</ul>
<p style="font-size:10px;">($(lang de:"alle Eintr&auml;ge, die eine g&uuml;ltige MAC-Adresse aufweisen" en:"all items with a valid MAC address"))</p>
EOF

sec_end
sec_begin "$(lang de:"WOL Interface" en:"WOL interface")"

cat << EOF
<h2>$(lang de:"Port des WOL-Webservers" en:"Port of WOL webserver"):</h2>
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$WOL_PORT")"></p>
EOF

sec_end
sec_begin "$(lang de:"Zugriff" en:"Access")"

cat << EOF
<p>$(lang de:"Benutzer" en:"User"): <input type="text" name="user" size="20" maxlength="255" value="$(html "$WOL_USER")"></p>
<p>$(lang de:"Passwort" en:"Password"): <input type="password" name="plain_passwd" size="20" maxlength="255" value="$(html "$WOL_PLAIN_PASSWD")"></p>
EOF

sec_end

