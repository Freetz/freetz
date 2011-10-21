skins="$(ls /usr/share/skin)"
for skin in $skins; do
	check "$MOD_SKIN" $skin:${skin}
done

sec_begin '$(lang de:"Weboberfl&auml;che" en:"Web interface")'

cgi_print_radiogroup_service_starttype \
	"httpd" "$MOD_HTTPD" "$(lang de:"Starttyp der Weboberfl&auml;che" en:"Web interface start type")" "" 1

cgi_print_textline_p "httpd_user" "$MOD_HTTPD_USER" 15 "$(lang de:"Benutzername" en:"Username"):" \
	'<a href="/cgi-bin/passwd.cgi" target="_blank">$(lang de:"Passwort &auml;ndern" en:"change password")</a>'
cgi_print_textline_p "httpd_port" "$MOD_HTTPD_PORT" 5 "$(lang de:"Port" en:"Port"):"

cat << EOF
<h2>$(lang de:"Erweiterte Einstellungen" en:"Advanced settings")</h2>
<p>
$(lang de:"Eingeh&auml;ngte Partitionen auf" en:"Mounted partitions on"):
EOF

cgi_print_checkbox "mounted_sub" "$MOD_MOUNTED_SUB" "$(lang de:"Untermen&uuml;" en:"Submenu")"
cgi_print_checkbox "mounted_main" "$MOD_MOUNTED_MAIN" "$(lang de:"Hauptseite" en:"Mainpage")"
cgi_print_checkbox "mounted_umount" "$MOD_MOUNTED_UMOUNT" "$(lang de:"mit Kn&ouml;pfen" en:"with buttons")"

cat << EOF
</p>
EOF
if [ -r "/usr/lib/cgi-bin/mod/box_info.cgi" -o -r "/usr/lib/cgi-bin/mod/info.cgi" ]; then
	echo '<p> $(lang de:"Zus&auml;tzliche Status-Seiten" en:"Additional status pages"):'

	if [ -r "/usr/lib/cgi-bin/mod/box_info.cgi" ]; then
		cgi_print_checkbox "show_box_info" "$MOD_SHOW_BOX_INFO" "$(lang de:"Box-Info" en:"Box info")"
	fi
	if [ -r "/usr/lib/cgi-bin/mod/info.cgi" ]; then
		cgi_print_checkbox "show_freetz_info" "$MOD_SHOW_FREETZ_INFO" "$(lang de:"Freetz-Info" en:"Freetz info")"
	fi

	echo "</p>"
fi

cat << EOF
<p>$(lang de:"Skinauswahl" en:"Skin selection"):
EOF
for skin in $skins; do
	skin_nice_name="$(echo -n "${skin:0:1}" | tr [:lower:] [:upper:])${skin:1}"
	echo "<input id=\""$skin"\" type=\"radio\" name=\"skin\" value=\""$skin"\" "$(eval echo \$${skin}_chk)"><label for=\""$skin"\"> "$skin_nice_name"</label>"
done

cgi_print_textline_p "cgi_width" "$MOD_CGI_WIDTH" 4 "$(lang de:"Breite des Hauptinhalts" en:"Width of the main content area"):"
cgi_print_checkbox_p "show_memory_usage" "$MOD_SHOW_MEMORY_USAGE" "$(lang de:"Zeige Speicherverbrauch" en:"Show memory usage")"

sec_end
