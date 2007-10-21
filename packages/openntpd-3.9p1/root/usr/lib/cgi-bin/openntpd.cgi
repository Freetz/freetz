#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
anonym_chk=''

if [ "$OPENNTPD_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$OPENNTPD_MULTID" = "yes" ]; then multid_chk=' checked'; else nomultid_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end

sec_begin '$(lang de:"Multid NTP client deaktivieren" en:"Deactivate multid NTP client")'

cat << EOF
<p>
<input id="f1" type="radio" name="multid" value="yes"$multid_chk><label for="f1"> $(lang de:"Nein" en:"No")</label>
<input id="f2" type="radio" name="multid" value="no"$nomultid_chk><label for="f2"> $(lang de:"Ja" en:"Yes")</label>
</p>
EOF

sec_end

