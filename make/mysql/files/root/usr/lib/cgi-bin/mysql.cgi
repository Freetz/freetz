#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype "enabled" "$MYSQL_ENABLED" "" "" 0

sec_end

#

if [ "$FREETZ_PACKAGE_MYSQL_mysql" == "y" ]; then
sec_begin "$(lang de:"Anzeigen" en:"Show")"

cat << EOF
<ul>
<li><a href="$(href status mysql mysql_status)">$(lang de:"Status anzeigen" en:"Show status")</a></li>
</ul>
EOF

sec_end
fi

#

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cgi_print_textline_p "dir" "$MYSQL_DIR" 55/255 "$(lang de:"Verzeichnis" en:"Directory"): "
cgi_print_textline_p "host" "$MYSQL_HOST" 15/15 "$(lang de:"IP-Adresse" en:"IP address") (0.0.0.0 $(lang de:"f&uuml;r alle IPs" en:"means all IPs")): "
cgi_print_textline_p "port" "$MYSQL_PORT" 5/5 "$(lang de:"Port" en:"Port"): "

sec_end

#

sec_begin "$(lang de:"Erweitert" en:"Advanced")"

cgi_print_checkbox_p "loggen" "$MYSQL_LOGGEN" "$(lang de:"Logge allgemeines" en:"General log") "
cgi_print_checkbox_p "logerr" "$MYSQL_LOGERR" "$(lang de:"Logge Fehler" en:" Error log") "
cgi_print_textline_p "args" "$MYSQL_ARGS" 55/255 "$(lang de:"Zus&auml;tzliche Kommandozeilenparameter" en:"Additional command-line arguments"): "

sec_end

#

[ ! -e "$MYSQL_DIR" ] && setup=y
[ -x "$(which mysql)" ] && remote=y
if [ "$setup" == y -o "$remote" == y ]; then
sec_begin "$(lang de:"Hinweis" en:"Note")"

echo "<ul>"
if [ "$setup" == y ]; then
cat << EOF
<li>$(lang de:"Das Datenbankverzeichnis existiert nicht. Es kann so initialisiert werden" en:"The database directory does not exists. You could initiliaze it this way"): <i>rc.mysql setup</i></li>
EOF
else
[ "$remote" == y ] && cat << EOF
<li>$(lang de:"Root Zugriff aus dem Netzwerk" en:"Root acces by network"): <i>mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO root@'192.168.%' IDENTIFIED BY 'Gehaim';flush privileges;"</i></li>
<li>$(lang de:"Lokales root-Passwort zuweisen" en:"Set local root password"): <i>mysql -u root -e "set password=password('Gehaim')"</i></li>
EOF
fi
echo "</ul>"

sec_end
fi


