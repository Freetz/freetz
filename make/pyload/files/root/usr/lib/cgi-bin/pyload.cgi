#!/bin/sh

. /usr/lib/libmodcgi.sh


#

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype "enabled" "$PYLOAD_ENABLED" "" "" 0

sec_end

#

pyweb="$(grep -A9 '^webinterface -' /mod/pyload/pyload.conf 2>/dev/null | sed -n 's/.*"Activated" = \([a-zA-Z]*\).*/\1/p' | head -n1)"
if [ "$pyweb" == "True" -a "$(/mod/etc/init.d/rc.pyload status)" == "running" ]; then
sec_begin "$(lang de:"Anzeigen" en:"Show")"

cat << EOF
<ul>
<li><a href="/cgi-bin/pyload" target="_blank">$(lang de:"pyLoad Webinterface" en:"pyLoad web interface")</a></li>
</ul>
EOF

sec_end
fi

#

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cgi_print_textline_p "configdir" "$PYLOAD_CONFIGDIR" 55/255 "$(lang de:"pyLoad Verzeichnis" en:"pyLoad directory"): "

sec_end

#

sec_begin "$(lang de:"Hinweis" en:"Note")"

echo '<ul>'
if [ ! -s "$PYLOAD_CONFIGDIR/pyload.conf" ]; then
cat << EOF
<li>$(lang de:"pyLoad wurde noch nicht konfiguriert. Dazu bitte diesen Befehl in einem Terminal ausf&uuml;hren" en:"pyLoad is not configured. To do so, please run this in a terminal"): <i>rc.pyload setup</i></li>
EOF
fi
cat << EOF
<li>$(lang de:"Die Benutzerverwaltung kann so aufgerufen werden" en:"The user management can be run by"): <i>rc.pyload user</i></li>
</ul>
EOF

sec_end


