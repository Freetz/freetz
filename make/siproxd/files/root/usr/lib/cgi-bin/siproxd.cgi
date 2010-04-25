#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$SIPROXD_ENABLED" yes:auto "*":man

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
<ul>
<li><a href="$(href file siproxd conf)">$(lang de:"siproxd.conf bearbeiten" en:"Edit siproxd.conf")</a></li>
<li><a href="$(href file siproxd pwd)">$(lang de:"siproxd.pwd bearbeiten" en:"Edit siproxd.pwd")</a></li>
<li><a href="$(href file siproxd reg)">$(lang de:"siproxd.reg bearbeiten" en:"Edit siproxd.reg")</a></li>
</ul>
EOF

sec_end
