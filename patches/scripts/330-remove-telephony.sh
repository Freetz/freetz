[ "$FREETZ_REMOVE_TELEPHONY" == "y" ] || return 0

echo1 "removing telephony files"
if [ "$FREETZ_AVM_HAS_USB_HOST" == "y" ]; then
	rm_files \
	  $(find ${FILESYSTEM_MOD_DIR} ! -path '*/lib/*' -a -name '*isdn*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	  $(find ${FILESYSTEM_MOD_DIR}/lib/modules/2.6*/ -name '*isdn*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	  $(find ${FILESYSTEM_MOD_DIR} ! -path '*/lib/*' -a ! -name '*.cfg' -a -name '*voip*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(etc|proc|dev|sys|oldroot|var)/')
	[ "$FREETZ_AVM_HAS_USB_HOST_AHCI" != "y" ] && \
	  rm_files ${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit
else
	rm_files $(find ${FILESYSTEM_MOD_DIR} -name '*isdn*' -o -name '*iglet*' -o -name '*voip' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/')
fi

# libcapi cannot be removed in firmwares having libfaxsendlua.so, libfaxsendlua.so is required by /usr/www/cgi-bin/firmwarecfg
# this is also the reason why we don't remove libfaxsendlua.so
# TODO: AVM's version of libcapi can be removed if freetz' version of it is available. In order this to work we however need to symlink
# AVM's version to the freetz one (i.e. "to replace it"). AVM binaries know nothing about /usr/lib/freetz and will not find libcapi there.
if [ ! -e "${FILESYSTEM_MOD_DIR}/lib/libfaxsendlua.so" ] || ! isNeededEntry libcapi20.so "${FILESYSTEM_MOD_DIR}/lib/libfaxsendlua.so"; then
	rm_files $(find ${FILESYSTEM_MOD_DIR} -name 'libcapi*')
fi

rm_files \
  $(find ${FILESYSTEM_MOD_DIR} \( -name '*capi*' -a ! -name 'libcapi*' \) -o -name '*tam*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
  $(find ${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr -name 'libfon*' -o -name 'libtelcfg*') \
  $(find ${FILESYSTEM_MOD_DIR} -name 'voipd' -o -name 'telefon' -o -name 'pbd' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
  ${FILESYSTEM_MOD_DIR}/usr/bin/faxd \
  ${FILESYSTEM_MOD_DIR}/lib/modules/c55fw.hex \
  ${FILESYSTEM_MOD_DIR}/etc/init.d/S17-tam \
  ${FILESYSTEM_MOD_DIR}/etc/init.d/S11-piglet

echo1 "patching rc.S"
[ "$FREETZ_AVM_HAS_USB_HOST_AHCI" != "y" ] && \
  modsed '/microvoip_isdn_top.bit/d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed '/c55fw.hex/d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

echo1 "patching rc.conf"
modsed "s/CONFIG_FON=.*$/CONFIG_FON=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

menu2html_remove fon

# Webinterface Hauptseite
HOME_LUA="${HTML_LANG_MOD_DIR}/home/home.lua"
if [ -e "$HOME_LUA" ]; then
	echo1 "patching home.lua"

	# patcht Hauptseite > Kasten Komfortfunktionen
	homelua_disable tr_call_redirect  # Rufumleitung
	homelua_disable tr_tam.*          # Anrufbeantworter (5.2x=tr_tam 5.50=tr_tamcalls)
	homelua_disable IntFax_Display    # Facksimile
	homelua_disable tr_fonbook        # Telefonbuch
	homelua_disable tr_foncalls       # Anrufliste
	homelua_disable tr_internet_Sips  # Verbindungen (7570)

	# patcht Hauptseite > Kasten Anrufe
	modsed '/^{?537:759?}$/d' "$HOME_LUA"
	# heute: box.out(" <span class=\"cs_Details\">({?537:891?} "..tostring(g_coninf_data.CallsToday)..")</span>")
	# 7570: box.out([[ <span class="cs_Details">({?537:891?} ]]..tostring(g_coninf_data.CallsToday)..[[)</span>]])
	modsed '/box.out(.* <span class=.*cs_Details.*>.{?537:891?} .*tostring(g_coninf_data.CallsToday).*)<.span>.*)/d' "$HOME_LUA"
	# mehr: <a class="cs_more" href="<?lua box.out(get_link('/fon_num/foncalls.lua'))?>">{?537:36?}</a>
	modsed '/<a class="cs_more" href="<?lua box.out(get_link(..fon_num.foncalls.lua.))?>">{?537:36?}<.a>/d' "$HOME_LUA"
	# href: <a class="head_link" href="<?lua href.write('/fon_num/foncalls.lua') ?>">
	modsed 's/\(<a class="head_link" href="\)<?lua href.write(..fon_num.foncalls.lua.) ?>\(">\)/\1\2/' "$HOME_LUA"

	# patcht Hauptseite > Kasten Telefonbuch
	modsed '/^{?537:969?}$/d' "$HOME_LUA"
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

# patcht System > Firmware-Update > Firmware-Datei
# entfernt: "Hinweis: Es wird zur Zeit noch telefoniert. Wenn Sie das
# Firmware-Update jetzt starten, werden alle Telefongespraeche beendet."
modsed 's/^if next.calls. then$/if false then/' "${HTML_LANG_MOD_DIR}/system/update_file.lua"
