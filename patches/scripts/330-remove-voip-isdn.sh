[ "$FREETZ_REMOVE_VOIP_ISDN" == "y" ] || return 0

echo1 "removing VoIP & ISDN files"
if [ "$FREETZ_HAS_AVM_USB_HOST" == "y" ]; then
rm_files $(find ${FILESYSTEM_MOD_DIR} ! -path '*/lib/*' -a -name '*isdn*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	 $(find ${FILESYSTEM_MOD_DIR}/lib/modules/2.6*/ -name '*isdn*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	 $(find ${FILESYSTEM_MOD_DIR} ! -path '*/lib/*' -a ! -name '*.cfg' -a -name '*voip*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(etc|proc|dev|sys|oldroot|var)/')
else
	rm_files $(find ${FILESYSTEM_MOD_DIR} -name '*isdn*' -o -name '*iglet*' -o -name '*voip' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/')
fi

rm_files $(find ${FILESYSTEM_MOD_DIR} -name '*capi*' -o -name '*tam*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	 $(find ${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr -name 'libfon*' -o -name 'libtelcfg*') \
	 $(find ${FILESYSTEM_MOD_DIR} -name 'voipd' -o -name 'telefon' -o -name 'pbd' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/')

rm_files ${FILESYSTEM_MOD_DIR}/usr/bin/faxd \
	${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit \
	${FILESYSTEM_MOD_DIR}/lib/modules/c55fw.hex

echo1 "patching rc.S"
modsed '/microvoip_isdn_top.bit/d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed '/c55fw.hex/d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

echo1 "patching rc.conf"
modsed "s/CONFIG_FON=.*$/CONFIG_FON=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# Webinterface Hauptseite
HOME_LUA="${FILESYSTEM_MOD_DIR}/usr/www/all/home/home.lua"
if [ -e "$HOME_LUA" ]; then
	echo1 "patching home.lua"

	# patcht Hauptseite > Kasten Komfortfunktionen
	homelua_disable tr_call_redirect  # Rufumleitung
	homelua_disable tr_tam            # Anrufbeantworter
	homelua_disable IntFax_Display    # Facksimile
	homelua_disable tr_fonbook        # Telefonbuch
	homelua_disable tr_foncalls       # Anrufliste

	# patcht Hauptseite > Kasten Anrufe
	# heute: box.out(" <span class=\"cs_Details\">({?537:891?} "..tostring(g_coninf_data.CallsToday)..")</span>")
	modsed '/box.out(" <span class=."cs_Details.">.{?537:891?} "..tostring(g_coninf_data.CallsToday)..")<.span>")/d' "$HOME_LUA"
	# mehr: <a class="cs_more" href="<?lua box.out(get_link('/fon_num/foncalls.lua'))?>">{?537:36?}</a>
	modsed '/<a class="cs_more" href="<?lua box.out(get_link(..fon_num.foncalls.lua.))?>">{?537:36?}<.a>/d' "$HOME_LUA"
	# href: <a class="head_link" href="<?lua href.write('/fon_num/foncalls.lua') ?>">
	modsed 's/\(<a class="head_link" href="\)<?lua href.write(..fon_num.foncalls.lua.) ?>\(">\)/\1\2/' "$HOME_LUA"

	# patcht Hauptseite > Kasten Telefonbuch
	# zuletzt: <span class="cs_Details">({?537:67?})</span>
	modsed '/<span class="cs_Details">({?537:67?})<.span>/d' "$HOME_LUA"
	# mehr: <a class="cs_more" href="<?lua box.out(get_link('/fon_num/fonbuch.lua'))?>">{?537:405?}</a>
	modsed '/<a class="cs_more" href="<?lua box.out(get_link(..fon_num.fonbuch.lua.))?>">{?537:405?}<.a>/d' "$HOME_LUA"
	# href: <a class="head_link" href="<?lua href.write('/fon_num/fonbuch.lua') ?>">
	modsed 's/\(<a class="head_link" href="\)<?lua href.write(..fon_num.fonbuch.lua.) ?>\(">\)/\1\2/' "$HOME_LUA"

	# patcht Hauptseite > Kasten Verbindungen > Telefonie
	modsed '/str=str.."<td class=."..State_Led(led)..".><.td>"/d' "$HOME_LUA"
	modsed '/str=str.."<td ><a href=."..get_link(".fon_devices.fondevices.lua")..".>{?537:794?}<.a><.td>"/d' "$HOME_LUA"
	modsed '/str=str.."<td>"..status.."<.td>"/d' "$HOME_LUA"

fi
