#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SCANBUTTOND_ENABLED" "" "" 0
sec_end

sec_begin 'Scanbuttond Daemon'

cat << EOF
<p>
	<h2>Scanner initialization script</h2>
	<textarea name="INITSCANNER_SCRIPT" cols="78" rows="10">$(html "$SCANBUTTOND_INITSCANNER_SCRIPT")</textarea>
</p>
<p>
	<h2>Button-pressed script</h2>
	<textarea name="BUTTONPRESSED_SCRIPT" cols="78" rows="10">$(html "$SCANBUTTOND_BUTTONPRESSED_SCRIPT")</textarea>
</p>
EOF

sec_end
