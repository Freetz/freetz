[ "$FREETZ_REMOVE_MULTI_ANNEX_FIRMWARE_PRIME" == "y" -o \
  "$FREETZ_REMOVE_ANNEX_A_FIRMWARE" == "y" -o \
  "$FREETZ_REMOVE_ANNEX_B_FIRMWARE" == "y" -o \
  "$FREETZ_REMOVE_DSLD" == "y" ] || return 0
[ "$FREETZ_ADD_ANNEX_A_FIRMWARE" == "y" ] && return 0

if [ -e "${FILESYSTEM_MOD_DIR}/usr/www/all/home/home.lua" ]; then
	# patcht Hauptseite > Kasten Anschlüsse > DSL
	echo1 "hiding dsl"
	modsed 's/^\(function tr_connect_info_dsl\)()$/\1()\nreturn ""\nend\n\1_()/' \
	  "${FILESYSTEM_MOD_DIR}/usr/www/all/home/home.lua" "tr_connect_info_dsl_("
fi
