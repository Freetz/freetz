[ "$FREETZ_REMOVE_MULTI_ANNEX_FIRMWARE_PRIME" == "y" -o \
  "$FREETZ_REMOVE_ANNEX_A_FIRMWARE" == "y" -o \
  "$FREETZ_REMOVE_ANNEX_B_FIRMWARE" == "y" -o \
  "$FREETZ_REMOVE_DSLD" == "y" ] || return 0
[ "$FREETZ_ADD_ANNEX_A_FIRMWARE" == "y" ] && return 0
echo1 "hiding dsl"

rm_files \
  "${HTML_LANG_MOD_DIR}/internet/dsl_*.lua" \
  "${HTML_LANG_MOD_DIR}/internet/vdsl_profile.lua"

if [ -e "${HTML_LANG_MOD_DIR}/home/home.lua" ]; then
	# patcht Hauptseite > Kasten Anschluesse > DSL
	homelua_disable tr_connect_info_dsl
	# patcht Internet > Online-Monitor > Online-Monitor
	modsed \
	  '/^box.out(connection.create_connection_row("inetmon"))$/d' \
	  "${HTML_LANG_MOD_DIR}/internet/inetstat_monitor.lua"
	# patcht Internet > DSL-Informationen (lua)
	modsed \
	  's!not config.ATA or box.query("box:settings/ata_mode") ~= "1"!false!'\
	  "${HTML_LANG_MOD_DIR}/menus/menu_show.lua"
fi

# patcht Internet > DSL-Informationen (html)
modsed 's/\(setvariable var:showdslinfo \)./\10/' "${HTML_SPEC_MOD_DIR}/menus/menu2_internet.html"

# patcht Uebersicht > Anschlussinformationen
sedfile="${HTML_SPEC_MOD_DIR}/home/home.js"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	modsed '/cbDslStateDisplay[^(]/d' $sedfile
fi

# patcht Uebersicht > Anschluesse
mod_del_area \
  'document.write(DslStateLed(' \
  -1 \
  +3 \
  "${HTML_SPEC_MOD_DIR}/home/home.html"

