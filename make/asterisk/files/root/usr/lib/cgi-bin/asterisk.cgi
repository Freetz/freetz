#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$ASTERISK_ENABLED" "" "" 0
sec_end

#

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"
cgi_print_textline_p "configdir" "$ASTERISK_CONFIGDIR" 55/255 "$(lang de:"Konfigurationsverzeichnis" en:"Directory containing configuration files"): "
sec_end

#

sec_begin "$(lang de:"Dokumentation" en:"Documentation")"
cat << EOM
<ul>
<li><a target=blank href="https://wiki.asterisk.org/wiki/display/AST/Asterisk+11+Documentation">Asterisk 11 $(lang de:"Dokumentation" en:"documentation")</a></li>
</ul>
EOM
sec_end

#

sec_begin "$(lang de:"Hinweis" en:"Note")"
echo '<ul>'
if [ ! -s "$ASTERISK_CONFIGDIR/asterisk.conf" ]; then
cat << EOF
<li>$(lang de:"Asterisk wurde noch nicht konfiguriert. Dazu bitte diesen Befehl in einem Terminal ausf&uuml;hren" en:"Asterisk is not configured. To do so, please run this in a terminal"): <i>rc.asterisk setup</i></li>
EOF
fi
cat << EOF
<li>$(lang de:"Die Konsole kann so aufgerufen werden" en:"The console can be run by"): <i>rc.asterisk console</i></li>
</ul>
EOF
sec_end
