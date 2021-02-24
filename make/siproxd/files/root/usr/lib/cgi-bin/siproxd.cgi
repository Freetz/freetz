#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SIPROXD_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<ul>
<li><a href="$(href file siproxd conf)">$(lang de:"siproxd.conf bearbeiten" en:"Edit siproxd.conf")</a></li>
<li><a href="$(href file siproxd pwd)">$(lang de:"siproxd.pwd bearbeiten" en:"Edit siproxd.pwd")</a></li>
<li><a href="$(href file siproxd reg)">$(lang de:"siproxd.reg bearbeiten" en:"Edit siproxd.reg")</a></li>
</ul>
EOF

sec_end
