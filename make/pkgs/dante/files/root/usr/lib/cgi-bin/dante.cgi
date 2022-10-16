#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$DANTE_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<ul>
<li><a href="$(href file dante conf)">$(lang de:"sockd.conf bearbeiten" en:"Edit sockd.conf")</a></li>
</ul>
EOF

sec_end

