#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

inetd=false
[ -e /etc/default.inetd/inetd.cfg ] && inetd=true

check "$MOD_STOR_USELABEL" yes:stor_uselabel
check "$MOD_SHOW_BOX_INFO" yes:show_box_info
check "$MOD_SHOW_FREETZ_INFO" yes:show_freetz_info
check "$MOD_MOUNTED_MAIN" yes:mounted_main
check "$MOD_MOUNTED_SUB" yes:mounted_sub
check "$MOD_MOUNTED_UMOUNT" yes:mounted_umount
check "$MOD_CROND" yes:crond_auto "*":crond_man
check "$MOD_SWAP" yes:swap_auto "*":swap_man
check "$MOD_TELNETD" yes:telnetd_auto inetd:telnetd_inetd "*":telnetd_man
check "$MOD_HTTPD" yes:httpd_auto inetd:httpd_inetd "*":httpd_man

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
<p><input type="text" name="swap_size" size="3" maxlength="3" value="" /> MB <input type="button" value="$(lang de:"Swap-Datei anlegen" en:"Create swapfile")" onclick="window.open('/cgi-bin/create_swap.cgi?swap_file='+encodeURIComponent(document.forms[0].swap_file.value)+'&swap_size='+encodeURIComponent(document.forms[0].swap_size.value),'swapfilepopup','menubar=no,width=800,height=600,toolbar=no,resizable=yes,scrollbars=yes')" /></p>
EOF

sec_end
sec_begin 'telnetd'

cat << EOF
<h2>$(lang de:"Starttyp von telnetd" en:"telnetd start type")</h2>
<p>
<input id="t1" type="radio" name="telnetd" value="yes"$telnetd_auto_chk><label for="t1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="t2" type="radio" name="telnetd" value="no"$telnetd_man_chk><label for="t2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
if $inetd; then
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
if $inetd; then
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
$(lang de:"Eingeh&auml;ngte Partitionen auf" en:"Mounted partitions on"):
<input type="hidden" name="mounted_sub" value="no">
<input id="a2" type="checkbox" name="mounted_sub" value="yes"$mounted_sub_chk><label for="a2">$(lang de:"Untermen&uuml;" en:"Submenu")</label>
<input type="hidden" name="mounted_main" value="no">
<input id="a1" type="checkbox" name="mounted_main" value="yes"$mounted_main_chk><label for="a1">$(lang de:"Hauptseite" en:"Mainpage")</label>
<input type="hidden" name="mounted_umount" value="no">
<input id="a3" type="checkbox" name="mounted_umount" value="yes"$mounted_umount_chk><label for="a3">$(lang de:"mit Kn&ouml;pfen" en:"with buttons")</label>
</p>
EOF
if [ -r "/usr/lib/cgi-bin/mod/box_info.cgi" -o -r "/usr/lib/cgi-bin/mod/info.cgi" ]; then
	echo '<p> $(lang de:"Zus&auml;tzliche Status-Seiten" en:"Additional status pages"):'
fi
if [ -r "/usr/lib/cgi-bin/mod/box_info.cgi" ]; then
cat << EOF
<input type="hidden" name="show_box_info" value="no">
<input id="i1" type="checkbox" name="show_box_info" value="yes"$show_box_info_chk><label for="i1">$(lang de:"BOX-Info" en:"BOX info")</label>
EOF
fi
if [ -r "/usr/lib/cgi-bin/mod/info.cgi" ]; then
cat << EOF
<input type="hidden" name="show_freetz_info" value="no">
<input id="i2" type="checkbox" name="show_freetz_info" value="yes"$show_freetz_info_chk><label for="i2">$(lang de:"FREETZ-Info" en:"FREETZ info")</label>
EOF
fi
if [ -r "/usr/lib/cgi-bin/mod/box_info.cgi" -o -r "/usr/lib/cgi-bin/mod/info.cgi" ]; then
	echo "</p>"
fi
cat << EOF
<p>$(lang de:"Breite der Freetz-Weboberfläche" en:"Width of the Freetz webinterface"): <input type="text" name="cgi_width" size="4" maxlength="4" value="$(html "$MOD_CGI_WIDTH")"></p>
EOF

sec_end
if [ -r /usr/lib/libmodmount.sh ]; then 
sec_begin 'automount'
if [ -x /usr/sbin/blkid ]
then
cat << EOF
<p>
<input type="hidden" name="stor_uselabel" value="no">
<input id="m1" type="checkbox" name="stor_uselabel" value="yes"$stor_uselabel_chk><label for="m1">$(lang de:"Partitionname (falls vorhanden) als Mountpoint" en:"Use partition label (if defined) as mount point")</label>
</p>
EOF
fi
cat << EOF
<p>
$(lang de:"Pr&auml;fix für Mountpoints" en:"Prefix for mountpoints") (uStor) : <input type="text" name="stor_prefix" size="20" maxlength="20" value="$(html "$MOD_STOR_PREFIX")"></p>
</p>
EOF
sec_end
fi
