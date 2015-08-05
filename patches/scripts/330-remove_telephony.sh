[ "$FREETZ_REMOVE_TELEPHONY" == "y" ] || return 0

echo1 "removing telephony files"
if [ "$FREETZ_AVM_HAS_USB_HOST" == "y" ]; then
	rm_files \
	  $(find ${FILESYSTEM_MOD_DIR} ! -path '*/lib/*' -a -name '*isdn*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	  $(find ${FILESYSTEM_MOD_DIR}/lib/modules/2.6.*/ ${FILESYSTEM_MOD_DIR}/lib/modules/3.*.*/ -name '*isdn*' 2>/dev/null | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	  $(find ${FILESYSTEM_MOD_DIR} ! -path '*/lib/*' -a ! -name '*.cfg' -a -name '*voip*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(etc|proc|dev|sys|oldroot|var)/')
	[ "$FREETZ_AVM_HAS_USB_HOST_AHCI" != "y" ] && \
	  rm_files ${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit
else
	rm_files $(find ${FILESYSTEM_MOD_DIR} -name '*isdn*' -o -name '*iglet*' -o -name '*voip' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/')
fi

# libcapi cannot be removed in firmwares containing libfaxsend(lua).so, libfaxsend(lua).so is required by /usr/www/cgi-bin/firmwarecfg
# this is also the reason why we don't remove libfaxsend(lua).so
# TODO: AVM's version of libcapi can be removed if freetz' version of it is available. In order this to work we however need to symlink
# AVM's version to the freetz one (i.e. "to replace it"). AVM binaries know nothing about /usr/lib/freetz and will not find libcapi there.
libcapi_could_be_removed=y
for binary in \
	${FILESYSTEM_MOD_DIR}/lib/libfaxsend.so \
	${FILESYSTEM_MOD_DIR}/lib/libfaxsendlua.so \
	${FILESYSTEM_MOD_DIR}/usr/bin/csvd \
; do
	if [ -e "$binary" ] && isNeededEntry libcapi20.so "$binary"; then
		libcapi_could_be_removed=n
		break
	fi
done
[ "$libcapi_could_be_removed" == "y" ] && rm_files $(find ${FILESYSTEM_MOD_DIR} -name 'libcapi*')

rm_files \
  $(find ${FILESYSTEM_MOD_DIR} \( -name '*capi*' -a ! -name 'libcapi*' \) -o -name '*tam*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
  $(find ${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr -name 'libfon*' -o -name 'libtelcfg*') \
  $(find ${FILESYSTEM_MOD_DIR} -name 'voipd' -o -name 'telefon' -o -name 'pbd' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
  ${FILESYSTEM_MOD_DIR}/usr/bin/faxd \
  ${FILESYSTEM_MOD_DIR}/lib/modules/c55fw.hex \
  ${FILESYSTEM_MOD_DIR}/etc/init.d/S17-tam \
  ${FILESYSTEM_MOD_DIR}/etc/init.d/S17-isdn \
  ${FILESYSTEM_MOD_DIR}/etc/init.d/S11-piglet \
  ${HTML_SPEC_MOD_DIR}/fon/ \
  ${HTML_SPEC_MOD_DIR}/fon_config/ \
  ${HTML_SPEC_MOD_DIR}/menus/menu2_fon.html

echo1 "patching rc.S"
[ "$FREETZ_AVM_HAS_USB_HOST_AHCI" != "y" ] && \
  modsed '/microvoip_isdn_top.bit/d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed '/c55fw.hex/d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

echo1 "patching rc.conf"
modsed "s/CONFIG_FON=.*$/CONFIG_FON=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

menu2html_remove fon

# patcht Erweiterte Einstellungen
sedfile="${HTML_SPEC_MOD_DIR}/enhsettings/enhsettings.js"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	modsed 's/\(setvariable var:showTelefon \)./\10/g' $sedfile
fi

# patcht Uebersicht > Komfortfunktionen
sedfile="${HTML_SPEC_MOD_DIR}/home/home.html"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	for item in Tam IntFax Sperre Umleitung Callthrough Wecker1 Wecker2 Wecker3; do
		modsed "/ id=.tr${item}. /{N;N;N;N;//d}" $sedfile
	done
fi

# patcht Uebersicht: linkes Menue
sedfile="${HTML_SPEC_MOD_DIR}/menus/menu2_homehome.html"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	for target in foncalls fonbuch fondevices; do
		modsed "/.*jslGoTo('home','${target}').*/d" $sedfile
	done
fi

# patcht System > Nachtschaltung > Klingelsperre aktivieren
sedfile="${HTML_SPEC_MOD_DIR}/system/nacht.html"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	modsed '/id="uiViewUseNachtFon"/{N;//d}' $sedfile
fi

# patcht Telefonie
sedfile="${HTML_SPEC_MOD_DIR}/menus/menu2_konfig.html"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	modsed "/.*('fon','foncalls').*/d" $sedfile
fi

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
