#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg


sec_begin 'Starttyp'
cgi_print_radiogroup_service_starttype "enabled" "$SHADOWSOCKSR_ENABLED" "" "" 0
sec_end

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'
cat << EOF
<p>
<ul>
<li>
$(lang de:"Optionale Kommandozeilenarameter" en:"Optional command line parameters"):
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$SHADOWSOCKS_CMDLINE")"></li>
<li>
<a href="$(href file shadowsocksr conf)">$(lang de:"Konfigurationsdatei bearbeiten" en:"Edit configuration file")</a></li>
</ul>
</p>
EOF
sec_end
