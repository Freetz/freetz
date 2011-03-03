#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$BIND_ENABLED" yes:auto "*":man
check "$BIND_MULTID" yes:multid

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'
cat << EOF
<p>
$(lang de:"Optionale Parameter:" en:"Optional parameters:")
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$BIND_CMDLINE")">
</p>
<p>
<input type="hidden" name="multid" value="no">
<input id="m1" type="checkbox" name="multid" value="yes"$multid_chk><label for="m1">$(lang de:"Neustarten von multid um Port 53 nutzen zu können." en:"Restart multid to use port 53.")</label>
</p>
EOF
sec_end
