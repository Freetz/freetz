[ "$FREETZ_MODIFY_DSL_SETTINGS" == "y" ] || return 0
echo1 "patching dsl settings"

# allow applying patch
decrip_file "${HTML_LANG_MOD_DIR}/css/default/dsl_line_settings.css"

if [ "$FREETZ_AVM_VERSION_07_2X_MIN" == "y" ] ; then
	PVER="07_2X"
elif [ "$FREETZ_AVM_VERSION_07_1X_MIN" == "y" ] ; then
	PVER="07_1X"
elif [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] ; then
	PVER="07_0X"
elif [ "$FREETZ_AVM_VERSION_06_8X_MIN" == "y" ] ; then
	PVER="06_8X"
elif [ "$FREETZ_AVM_VERSION_06_5X_MIN" == "y" ] ; then
	PVER="06_5X"
fi

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/831-extend-dsl_line_settings-speed/831-extend-dsl_line_settings-speed_${PVER}.patch"

