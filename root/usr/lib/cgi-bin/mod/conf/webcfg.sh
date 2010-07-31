check "$MOD_HTTPD" yes:httpd_auto inetd:httpd_inetd "*":httpd_man
check "$MOD_SHOW_BOX_INFO" yes:show_box_info
check "$MOD_SHOW_FREETZ_INFO" yes:show_freetz_info
check "$MOD_MOUNTED_MAIN" yes:mounted_main
check "$MOD_MOUNTED_SUB" yes:mounted_sub
check "$MOD_MOUNTED_UMOUNT" yes:mounted_umount

sec_begin '$(lang de:"Weboberfl&auml;che" en:"Web interface")'

cat << EOF
<h2>$(lang de:"Starttyp der Weboberfl&auml;che" en:"Web interface start type")</h2>
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
<p>$(lang de:"Benutzername" en:"Username"): <input type="text" name="httpd_user" size="15" maxlength="15" value="$(html "$MOD_HTTPD_USER")"> <a href="/cgi-bin/passwd.cgi" target="_blank">$(lang de:"Passwort &auml;ndern" en:"change password")</a></p>
<p>$(lang de:"Port" en:"Port"): <input type="text" name="httpd_port" size="5" maxlength="5" value="$(html "$MOD_HTTPD_PORT")"></p>
<h2>$(lang de:"Erweiterte Einstellungen" en:"Advanced settings")</h2>
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
<p><a href="/cgi-bin/skin.cgi" target="_blank">$(lang de:"Aussehen einstellen (Skins)" en:"Change look (skins)")</a></p>
<p>$(lang de:"Breite der Freetz-Weboberfl&auml;che" en:"Width of the Freetz webinterface"): <input type="text" name="cgi_width" size="4" maxlength="4" value="$(html "$MOD_CGI_WIDTH")"></p>
EOF

sec_end
