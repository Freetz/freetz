#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
anonym_chk=''

if [ "$OPENNTPD_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$OPENNTPD_MULTID" = "yes" ]; then multid_chk=' checked'; else nomultid_chk=' checked'; fi

echo $nomultid_chk
echo $multid_chk

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> "Automatisch"</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> "Manuell"</label>
</p>
EOF

sec_end

sec_begin 'Multid NTP client deaktivieren'

cat << EOF
<p>
<input id="f1" type="radio" name="multid" value="yes"$multid_chk><label for="f1"> "Nein"</label>
<input id="f2" type="radio" name="multid" value="no"$nomultid_chk><label for="f2"> "Ja"</label>
</p>
EOF

sec_end

