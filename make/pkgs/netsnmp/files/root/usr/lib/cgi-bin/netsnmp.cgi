#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$NETSNMP_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<ul>
<li><a href="$(href file netsnmp conf)">$(lang de:"snmpd.conf bearbeiten" en:"Edit snmpd.conf")</a></li>
</ul>
EOF

sec_end
