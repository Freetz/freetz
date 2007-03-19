#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
pwdauth_yes_chk=''; pwdauth_no_chk=''

if [ "$KNOCK_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manuell</label>
</p>
EOF

sec_end
sec_begin 'Anzeigen'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=knockd_conf">Knockd config bearbeiten</a></li>
</ul>
EOF

sec_end
sec_begin 'Port-Knock Server'

cat << EOF
<h2>Der Port-Knock Server horcht an:</h2>
<p>Interface: <input type="text" name="interface" size="6" maxlength="8" value="$(httpd -e "$KNOCK_INTERFACE")"></p>
EOF

sec_end
