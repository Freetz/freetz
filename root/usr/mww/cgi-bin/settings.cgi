#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /usr/lib/libmodfrm.sh

[ -r /mod/etc/conf/mod.cfg ] && . /mod/etc/conf/mod.cfg

inetd=''
[ -e /etc/default.inetd/inetd.cfg ] && inetd='true'

crond_auto_chk=''; crond_man_chk=''
swap_auto_chk=''; swap_man_chk=''
telnetd_auto_chk=''; telnetd_man_chk=''; telnet_inetd_chk='';
httpd_auto_chk=''; httpd_man_chk=''; httpd_inetd_chk='';
mounted_main_chk='';mounted_sub_chk='';

if [ "$MOD_MOUNTED_MAIN" = "yes" ]; then mounted_main_chk=' checked'; fi
if [ "$MOD_MOUNTED_SUB" = "yes" ]; then mounted_sub_chk=' checked'; fi
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
<h2>Swap ($(lang de:"Beispiel:" en:"e.g.") /var/media/ftp/uStor01/swapfile $(lang de:"oder" en:"or") /dev/sda1)</h2>
<p>Swap: <input type="text" name="swap_file" size="50" maxlength="50" value="$(html "$MOD_SWAP_FILE")"></p>
<p><input type="text" name="swap_size" size="3" maxlength="2" value="" /> MB <input type="button" value="$(lang de:"Swap-Datei anlegen" en:"Create swapfile")" onclick="window.open('/cgi-bin/create_swap.cgi?swap_file='+encodeURIComponent(document.forms[0].swap_file.value)+'&swap_size='+encodeURIComponent(document.forms[0].swap_size.value),'$(lang de:"Anlegen der Swap-Datei" en:"Swapfile creation")','menubar=no,width=800,height=600,toolbar=no,resizable=yes,scrollbars=yes')" /></p>
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
<p>$(lang de:"Benutzername f&uuml;r Weboberfl&auml;che" en:"username for webinterface"): <input type="text" name="httpd_user" size="15" maxlength="15" value="$(html "$MOD_HTTPD_USER")"> <a href="/cgi-bin/passwd.cgi"><u>$(lang de:"Passwort &auml;ndern" en:"change password")</u></a></p>
<p>$(lang de:"Port der Weboberfl&auml;che" en:"Port of webinterface"): <input type="text" name="httpd_port" size="5" maxlength="5" value="$(html "$MOD_HTTPD_PORT")"></p>
<h1>$(lang de:"Erweiterte Einstellungen" en:"Advanced settings")</h1>
<p>
$(lang de:"Gemountete Partitionen auf" en:"Mounted partitions on"):
<input type="hidden" name="mounted_sub" value="no">
<input id="a2" type="checkbox" name="mounted_sub" value="yes"$mounted_sub_chk><label for="a2">$(lang de:"Untermen&uuml;" en:"Submenu")</label>
<input type="hidden" name="mounted_main" value="no">
<input id="a1" type="checkbox" name="mounted_main" value="yes"$mounted_main_chk><label for="a1">$(lang de:"Hauptseite" en:"Mainpage")</label>
</p>
<p>$(lang de:"Breite des Freetz-Webinterfaces" en:"Width of the Freetz webinterface"): <input type="text" name="cgi_width" size="4" maxlength="4" value="$(html "$MOD_CGI_WIDTH")"></p>
EOF

sec_end
frm_end 'mod'
cgi_end
