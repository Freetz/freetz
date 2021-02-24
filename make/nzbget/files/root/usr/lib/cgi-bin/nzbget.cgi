#!/bin/sh

. /usr/lib/libmodcgi.sh


#

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype "enabled" "$NZBGET_ENABLED" "" "" 0

sec_end

#

if [ "$(/mod/etc/init.d/rc.nzbget status)" == "running" ]; then
sec_begin "$(lang de:"Anzeigen" en:"Show")"

cat << EOF
<ul>
<li><a href="/cgi-bin/nzbget" target="_blank">$(lang de:"NZBGet Webinterface" en:"NZBGet web interface")</a></li>
</ul>
EOF

sec_end
fi

#

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cgi_print_textline_p "configdir" "$NZBGET_CONFIGDIR" 55/255 "$(lang de:"NZBGet Verzeichnis" en:"NZBGet directory"): "

sec_end

#
