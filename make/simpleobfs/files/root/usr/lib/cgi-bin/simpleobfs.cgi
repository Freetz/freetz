#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg


sec_begin 'Starttyp'
cgi_print_radiogroup_service_starttype "enabled" "$SIMPLEOBFS_ENABLED" "" "" 0
sec_end

sec_begin 'Konfiguration'
cat << EOF
<ul>
<li>
Optionale Kommandozeilenarameter:
EOF
cgi_print_textline_p "cmdline" "$SIMPLEOBFS_CMDLINE" 20/255 "Optionen: "
cat << EOF
<li>
<a href="$(href file simpleobfs conf)">Konfigurationsdatei bearbeiten</a></li>
</ul>
EOF
sec_end
