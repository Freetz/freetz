#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

disabled_chk=''; inetd_chk=''

case "$RCAPID_ENABLED" in inetd) inetd_chk=' checked';; *) disabled_chk=' checked';;esac

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e2" type="radio" name="enabled" value="no"$disabled_chk><label for="e2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
EOF
if [ -e "/etc/default.inetd/inetd.cfg" ]; then
cat << EOF
<input id="e3" type="radio" name="enabled" value="inetd"$inetd_chk><label for="e3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
fi
cat << EOF
</p>
EOF

sec_end
sec_begin '$(lang de:"Remote CAPI Daemon" en:"Remote CAPI daemon")'

cat << EOF
<h2>$(lang de:"Der Remote CAPI Daemon ist gebunden an" en:"The remote CAPI daemon is listening on"):</h2>
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$RCAPID_PORT")"></p>
EOF

sec_end
