#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$SCANBUTTOND_ENABLED" yes:auto "*":man

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
cat << EOF
</p>
EOF

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
