#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SER2NET_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<ul>
<li><a href="$(href file ser2net conf)">$(lang de:"ser2net.conf bearbeiten" en:"Edit ser2net.conf")</a></li>
</ul>
EOF

sec_end

