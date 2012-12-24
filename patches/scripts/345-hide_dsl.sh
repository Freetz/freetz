[ "$FREETZ_REMOVE_MULTI_ANNEX_FIRMWARE_PRIME" == "y" -o \
  "$FREETZ_REMOVE_ANNEX_A_FIRMWARE" == "y" -o \
  "$FREETZ_REMOVE_ANNEX_B_FIRMWARE" == "y" -o \
  "$FREETZ_REMOVE_DSLD" == "y" ] || return 0
[ "$FREETZ_ADD_ANNEX_A_FIRMWARE" == "y" ] && return 0

if [ -e "${FILESYSTEM_MOD_DIR}/usr/www/all/home/home.lua" ]; then
	echo1 "hiding dsl"
	# patcht Hauptseite > Kasten Anschlüsse > DSL
	homelua_disable tr_connect_info_dsl
	# patcht Internet > Online-Monitor > Online-Monitor
	modsed \
	  '/^box.out(connection.create_connection_row("inetmon"))$/d' \
	  "${FILESYSTEM_MOD_DIR}/usr/www/all/internet/inetstat_monitor.lua"
	# patcht Internet > DSL-Informationen
	modsed \
	  's!not config.ATA or box.query("box:settings/ata_mode") ~= "1"!false!'\
	  "${FILESYSTEM_MOD_DIR}/usr/www/all/menus/menu_show.lua"
fi

rm_files \
  "${FILESYSTEM_MOD_DIR}/usr/www/all/internet/dsl_*.lua" \
  "${FILESYSTEM_MOD_DIR}/usr/www/all/internet/vdsl_profile.lua"

