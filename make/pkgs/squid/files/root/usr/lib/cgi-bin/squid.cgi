#!/bin/sh

. /usr/lib/libmodcgi.sh


#

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype \
	"enabled" "$SQUID_ENABLED" "" "" 0

sec_end

#

sec_begin "$(lang de:"Status" en:"Status")"

cat << EOF
<ul>
<li><a href="$(href status squid squid_log)">$(lang de:"Logdatei anzeigen" en:"Show logfile")</a></li>
</ul>
EOF

sec_end

#

sec_begin "$(lang de:"Squid" en:"Squid")"

cgi_print_textline_p "port" "$SQUID_PORT" 5/5 "$(lang de:"Port" en:"Port"): "
cgi_print_textline_p "localnet" "$SQUID_LOCALNET" 31/31 "$(lang de:"Lokales Netzwerk" en:"Local network"): "

cgi_print_textline_p "cache_dir" "$SQUID_CACHE_DIR" 45/255 "$(lang de:"Pfad f&uuml;r Cache" en:"Path for cache"): "
cgi_print_textline_p "coredump_dir" "$SQUID_COREDUMP_DIR" 45/255 "$(lang de:"Pfad f&uuml;r Coredumps" en:"Path for coredumps"): "
cgi_print_textline_p "log_dir" "$SQUID_LOG_DIR" 45/255 "$(lang de:"Pfad f&uuml;r Logdateien" en:"Path for logfiles"): "

sec_end

#

sec_begin "$(lang de:"Cachegr&ouml;&szlig;e" en:"Cache size")"

echo '<font color="red">$(lang de:"Diese Werte sollten nur von erfahrenen Benutzern ver&auml;ndert werden" en:"These values  should only be altered by experienced users")!</font><br>'

cgi_print_textline_p "cache_params" "$SQUID_CACHE_PARAMS" 5/5 "$(lang de:"Speicherplatz" en:"Amount of disk space") (MB): "
cgi_print_textline_p "cache_param2" "$SQUID_CACHE_PARAM2" 5/5 "$(lang de:"Verzeichnisse 1. Ebene" en:"First-level subdirectories"): "
cgi_print_textline_p "cache_param3" "$SQUID_CACHE_PARAM3" 5/5 "$(lang de:"Verzeichnisse 2. Ebene" en:"Second-level subdirectories"): "

sec_end

