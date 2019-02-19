[ "$FREETZ_MODIFY_DSL_SETTINGS" == "y" ] || return 0;

echo1 "patching dsl settings"

# allow applying patch
[ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] && modsed 's/{/ {\n/g;s/}/\n}\n/g;s/;/;\n/g' "${HTML_LANG_MOD_DIR}/css/default/dsl_line_settings.css"

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/831-extend-dsl_line_settings-speed_${FREETZ_TYPE_PREFIX_SERIES_SUBDIR}.patch"

