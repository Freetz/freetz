#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$OIDENTD_ENABLED" yes:auto inetd "*":man


sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
[ -e /mod/etc/default.inetd/inetd.cfg ] &&
cat << EOF
<input id="e3" type="radio" name="enabled" value="inetd"$inetd_chk><label for="e3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
cat << EOF
</p>
EOF

sec_end
sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cat << EOF
<p>
<a href="$(href file oidentd conf)">$(lang de:"Zum Bearbeiten der oidentd.conf hier klicken." en:"To edit the oidentd.conf click here.")</a>
</p>
<p>
$(lang de:"Optionale Parameter (au&szlig;er -I und -C):" en:"Optional parameters (except -I and -C):")
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$OIDENTD_CMDLINE")">
</p>
EOF

sec_end

