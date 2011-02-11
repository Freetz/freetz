#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk='' ;
if [ "$NFSD_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Konfiguration bearbeiten" en:"Edit configuration")'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=exports"> $(lang de:"/etc/exports bearbeiten" en:"edit /etc/exports")</a></li>
<li><a href="/cgi-bin/file.cgi?id=hosts_allow"> $(lang de:"/etc/hosts.allow bearbeiten" en:"edit /etc/hosts.allow")</a></li>
<li><a href="/cgi-bin/file.cgi?id=hosts_deny"> $(lang de:"/etc/hosts.deny bearbeiten" en:"edit /etc/hosts.deny")</a></li>

</ul>
EOF

sec_end