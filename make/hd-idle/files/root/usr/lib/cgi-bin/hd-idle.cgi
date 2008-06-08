#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''

if [ $HD_IDLE_ENABLED = yes ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p><input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label
for="e1"> $(lang de:"Automatisch" en:"Automatic")</label><input id="e2" type="radio"
name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label></p>
EOF

sec_end

sec_begin '$(lang de:"Optionen" en:"Options")'
cat << EOF
<p><label for="idletime">$(lang de:"Leerlaufzeit" en:"Idle time"):</label> <input
id="idletime" size="5" maxlength="8" type="text" name="idletime"
value="$(httpd -e "$HD_IDLE_IDLETIME")"> $(lang de:"Sekunden" en:"seconds")</p>
EOF
sec_end
