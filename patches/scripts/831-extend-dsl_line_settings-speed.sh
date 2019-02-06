[ "$FREETZ_MODIFY_DSL_SETTINGS" == "y" ] || return 0;

echo1 "patching dsl settings"

if [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] ; then
	PVER="07_0X"
elif [ "$FREETZ_AVM_VERSION_06_8X_MIN" == "y" ] ; then
	PVER="06_8X"
elif [ "$FREETZ_AVM_VERSION_06_5X_MIN" == "y" ] ; then
	PVER="06_5X"
fi

# allow applying patch
[ "$PVER" == "07_0X" ] && modsed 's/{/ {\n/g;s/}/\n}\n/g;s/;/;\n/g' "${HTML_LANG_MOD_DIR}/css/default/dsl_line_settings.css"

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/831-extend-dsl_line_settings-speed_${PVER}.patch"

