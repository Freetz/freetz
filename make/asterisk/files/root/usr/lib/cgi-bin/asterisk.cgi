#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cgi_print_radiogroup_service_starttype "enabled" "$ASTERISK_ENABLED" "" "" 0
sec_end

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'
cgi_print_textline_p "configdir" "$ASTERISK_CONFIGDIR" 55/255 "$(lang de:"Konfigurationsverzeichnis" en:"Directory containing configuration files"): "
sec_end

sec_begin '$(lang de:"Dokumentation" en:"Documentation")'
cat << EOM
<ul>
<li><a href="http://www.asterisk.org/astdocs/asterisk.html">Asterisk Reference Information</a></li>
<li><a href="https://wiki.asterisk.org/wiki/display/AST/Asterisk+11+Documentation">Asterisk 11 Documentation</a></li>
</ul>
EOM
sec_end
