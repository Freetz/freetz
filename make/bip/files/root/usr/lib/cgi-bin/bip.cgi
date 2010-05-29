#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$BIP_ENABLED" yes:auto "*":man

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
sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cat << EOF
<p>
<a href="$(href file bip conf)">$(lang de:"Zum Bearbeiten der bip.conf hier klicken." en:"To edit the bip.conf click here.")</a>
</p>
<p>
$(lang de:"Optionale Parameter (au&szlig;er -f):" en:"Optional parameters (except -f):")
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$BIP_CMDLINE")">
</p>
EOF

sec_end

