#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SUNDTEK_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Informationen" en:"Informations")"

echo "$(lang de:"Treiberversion" en:"Driver version"):"
echo -n '<pre><FONT SIZE=-1>'
sundtek-mediasrv --build 2>&1 | html
echo '</FONT></pre>'

if [ "$(/mod/etc/init.d/rc.sundtek status 2>/dev/null)" == "running" ]; then

	echo "$(lang de:"Unterst&uuml;tzte Hardware" en:"Supported hardware"):"
	echo -n '<pre><FONT SIZE=-1>'
	sundtek-mediaclient  --enumdevices 2>&1 | grep -EA1 "^device|SERIAL" | sed '2,3d' | html
	echo '</FONT></pre>'

	echo "$(lang de:"Verbundene Clients" en:"Connected clients"):"
	echo -n '<pre><FONT SIZE=-1>'
	sundtek-mediaclient  --lc 2>&1 | grep -vE '^\*|^ *$' | html
	echo '</FONT></pre>'

fi
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"
cat << EOF
$(lang de:"Parameter f&uuml;r 'sundtek-mediaclient' (einer pro Zeile)" en:"Parameters for 'sundtek-mediaclient' (one per row)")
<p><textarea name="config" rows="9" cols="59" maxlength="255">$(html "$SUNDTEK_CONFIG")</textarea></p>
EOF
sec_end
