#!/bin/sh


. /usr/lib/libmodcgi.sh

check "$SUNDTEK_ENABLED" yes:auto "*":man

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Informationen" en:"Informations")'

echo "$(lang de:"Treiberversion" en:"Driver version"):"
echo -n '<pre><FONT SIZE=-1>'
mediasrv --build 2>&1 | html
echo '</FONT></pre>'

if [ "$(/mod/etc/init.d/rc.sundtek status 2>/dev/null)" == "running" ]; then

	echo "$(lang de:"Unterst&uuml;tzte Hardware" en:"Supported hardware"):"
	echo -n '<pre><FONT SIZE=-1>'
	mediaclient  --enumdevices 2>&1 | grep -C1 'SERIAL' | html
	echo '</FONT></pre>'

	echo "$(lang de:"Verbundene Clients" en:"Connected clients"):"
	echo -n '<pre><FONT SIZE=-1>'
	mediaclient  --lc 2>&1 | grep -vE '^\*|^ *$' | html
	echo '</FONT></pre>'

fi
sec_end

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'
cat << EOF
$(lang de:"Parameter f&uuml;r 'mediaclient' (einer pro Zeile)" en:"Parameters for 'mediaclient' (one per row)")
<p><textarea name="config" rows="9" cols="59" maxlength="255">$(html "$SUNDTEK_CONFIG")</textarea></p>
EOF
sec_end
