#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$NFSD_ENABLED" yes:auto "*":man

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
<li><a href="$(href file nfsd exports)"> $(lang de:"/etc/exports bearbeiten" en:"edit /etc/exports")</a></li>
<li><a href="$(href file nfsd hosts_allow)"> $(lang de:"/etc/hosts.allow bearbeiten" en:"edit /etc/hosts.allow")</a></li>
<li><a href="$(href file nfsd hosts_deny)"> $(lang de:"/etc/hosts.deny bearbeiten" en:"edit /etc/hosts.deny")</a></li>

</ul>
EOF

