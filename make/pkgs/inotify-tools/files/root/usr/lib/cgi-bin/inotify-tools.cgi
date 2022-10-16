#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$INOTIFY_TOOLS_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Logdatei" en:"Log file")"

cat << EOF
<p>
<label for="i1">$(lang de:"Dateiname" en:"File name")
<input type="text" name="logfile" size="55" maxlength="250" value="$(html "$INOTIFY_TOOLS_LOGFILE")"></label>
</p>
EOF

sec_end
