#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$UMURMUR_ENABLED" yes:auto "*":man
check "$UMURMUR_REALTIME" yes:realtime

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="auto" type="radio" name="enabled" value="yes"$auto_chk><label for="auto"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="manual" type="radio" name="enabled" value="no"$man_chk><label for="manual"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Priorit&auml;t" en:"Priority")'
cat << EOF
<p>
<input type="hidden" name="realtime" value="no">
<input id="realtime" type="checkbox" name="realtime" value="yes"$realtime_chk><label for="realtime"> $(lang de:"Mit Realtime-Priorit&auml;t starten" en:"Run with realtime priority")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Konfigurationsdatei" en:"Configuration file")'
cat << EOF
<p>
<textarea id="config" style="width: 500px; " name="config" rows="30" cols="80" wrap="off">$(html "$UMURMUR_CONFIG")</textarea>
</p>
EOF
sec_end
