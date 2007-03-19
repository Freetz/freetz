#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /usr/lib/libmodfrm.sh

[ -r "/mod/etc/conf/mod.cfg" ] && . /mod/etc/conf/mod.cfg

crond_auto_chk=''; crond_man_chk=''
telnetd_auto_chk=''; telnetd_man_chk=''
httpd_auto_chk=''; httpd_man_chk=''

if [ "$MOD_CROND" = "yes" ]; then crond_auto_chk=' checked'; else crond_man_chk=' checked'; fi
if [ "$MOD_TELNETD" = "yes" ]; then telnetd_auto_chk=' checked'; else telnetd_man_chk=' checked'; fi
if [ "$MOD_HTTPD" = "yes" ]; then httpd_auto_chk=' checked'; else httpd_man_chk=' checked'; fi

cgi_begin '$(lang de:"Einstellungen" en:"Settings")' 'settings'
frm_begin 'mod'
sec_begin 'crond'

cat << EOF
<h2>$(lang de:"Starttyp von crond" en:"crond start type")</h2>
<p>
<input id="c1" type="radio" name="crond" value="yes"$crond_auto_chk><label for="c1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="c2" type="radio" name="crond" value="no"$crond_man_chk><label for="c2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin 'telnetd'

cat << EOF
<h2>$(lang de:"Starttyp von telnetd" en:"telnetd start type")</h2>
<p>
<input id="t1" type="radio" name="telnetd" value="yes"$telnetd_auto_chk><label for="t1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="t2" type="radio" name="telnetd" value="no"$telnetd_man_chk><label for="t2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin 'webcfg'

cat << EOF
<h2>$(lang de:"Starttyp der Weboberfl&auml;che" en:"webinterface start type")</h2>
<p>
<input id="w1" type="radio" name="httpd" value="yes"$httpd_auto_chk><label for="w1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="w2" type="radio" name="httpd" value="no"$httpd_man_chk><label for="w2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
<h2>$(lang de:"Port der Weboberfl&auml;che (erfordert Neustart)" en:"Port of webinterface (restart required)")</h2>
<p>Port: <input type="text" name="httpd_port" size="5" maxlength="5" value="$(httpd -e "$MOD_HTTPD_PORT")"></p>
EOF

sec_end
frm_end 'mod'
cgi_end
