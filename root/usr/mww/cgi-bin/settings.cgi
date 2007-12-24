#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /usr/lib/libmodfrm.sh

[ -r "/mod/etc/conf/mod.cfg" ] && . /mod/etc/conf/mod.cfg

inetd=''
[ -e "/etc/default.inetd/inetd.cfg" ] && inetd='true'

crond_auto_chk=''; crond_man_chk=''
swap_auto_chk=''; swap_man_chk=''
telnetd_auto_chk=''; telnetd_man_chk=''; telnet_inetd_chk='';
httpd_auto_chk=''; httpd_man_chk=''; httpd_inetd_chk='';

if [ "$MOD_CROND" = "yes" ]; then crond_auto_chk=' checked'; else crond_man_chk=' checked'; fi
if [ "$MOD_SWAP" = "yes" ]; then swap_auto_chk=' checked'; else swap_man_chk=' checked'; fi
case "$MOD_TELNETD" in yes) telnetd_auto_chk=' checked';; inetd) telnetd_inetd_chk=' checked';; *) telnetd_man_chk=' checked';; esac
case "$MOD_HTTPD" in yes) httpd_auto_chk=' checked';; inetd) httpd_inetd_chk=' checked';; *) httpd_man_chk=' checked';; esac

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
sec_begin 'swap'

cat << EOF
<h2>$(lang de:"Starttyp von swap" en:"swap start type")</h2>
<p>
<input id="s1" type="radio" name="swap" value="yes"$swap_auto_chk><label for="s1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="s2" type="radio" name="swap" value="no"$swap_man_chk><label for="s2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
<h2>Swap ($(lang de:"Beispiel:" en:"e.g.") /var/media/ftp/uStor01/swapfile $(lang de:"oder" en:"or") /dev/sda1</h2>
<p>Swap: <input type="text" name="swap_file" size="50" maxlength="50" value="$(httpd -e "$MOD_SWAP_FILE")"></p>
EOF

sec_end
sec_begin 'telnetd'

cat << EOF
<h2>$(lang de:"Starttyp von telnetd" en:"telnetd start type")</h2>
<p>
<input id="t1" type="radio" name="telnetd" value="yes"$telnetd_auto_chk><label for="t1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="t2" type="radio" name="telnetd" value="no"$telnetd_man_chk><label for="t2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
if [ "true" == $inetd ]; then
cat << EOF
<input id="t3" type="radio" name="telnetd" value="inetd"$telnetd_inetd_chk><label for="t3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
fi
cat << EOF
</p>
EOF

sec_end
sec_begin 'webcfg'

cat << EOF
<h2>$(lang de:"Starttyp der Weboberfl&auml;che" en:"webinterface start type")</h2>
<p>
<input id="w1" type="radio" name="httpd" value="yes"$httpd_auto_chk><label for="w1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="w2" type="radio" name="httpd" value="no"$httpd_man_chk><label for="w2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
if [ "true" == $inetd ]; then
cat << EOF
<input id="w3" type="radio" name="httpd" value="inetd"$httpd_inetd_chk><label for="w3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
fi
cat << EOF
</p>
<h2>$(lang de:"Port der Weboberfl&auml;che (erfordert Neustart)" en:"Port of webinterface (restart required)")</h2>
<p>Port: <input type="text" name="httpd_port" size="5" maxlength="5" value="$(httpd -e "$MOD_HTTPD_PORT")"></p>
EOF

sec_end
frm_end 'mod'
cgi_end
