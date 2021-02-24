#!/bin/sh

. /usr/lib/libmodcgi.sh

check "$UMURMUR_REALTIME" yes:realtime

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$UMURMUR_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Priorit&auml;t" en:"Priority")"
cat << EOF
<p>
<input type="hidden" name="realtime" value="no">
<input id="realtime" type="checkbox" name="realtime" value="yes"$realtime_chk><label for="realtime"> $(lang de:"Mit Realtime-Priorit&auml;t starten" en:"Run with realtime priority")</label>
</p>
EOF
sec_end

sec_begin "$(lang de:"Konfigurationsdatei" en:"Configuration file")"
cat << EOF
<p>
<textarea id="config" style="width: 500px; " name="config" rows="30" cols="80" wrap="off">$(html "$UMURMUR_CONFIG")</textarea>
</p>
EOF
sec_end
