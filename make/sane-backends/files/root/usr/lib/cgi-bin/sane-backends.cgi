#!/bin/sh


. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype \
	"enabled" "$SANE_BACKENDS_ENABLED" "" "" 1

sec_end
sec_begin "$(lang de:"Sane Daemon" en:"Sane Daemon")"

cat << EOF
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$SANE_BACKENDS_PORT")"> ($(lang de:"Diese Einstellung wirkt nur im Inetd-Modus" en:"This setting does only work in inetd mode").)</p>
<p>
<h2>$(lang de:"Erlaube Zugriff von (ein Host/Netzbereich pro Zeile)" en:"Permit access from (one host/range per line)")</h2>
<textarea name="permitted_hosts" cols="50" rows="3" maxlength="255">$(html "$SANE_BACKENDS_PERMITTED_HOSTS")</textarea>
</p>
EOF

sec_end
