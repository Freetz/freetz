[ "$FREETZ_MODIFY_DSL_WARNING" == "y" ] || return 0
echo1 "patching dsl overview"

if [ "$FREETZ_AVM_VERSION_07_2X_MIN" == "y" ] ; then
	PVER="07_2X"
elif [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] ; then
	PVER="07_0X"
elif [ "$FREETZ_AVM_VERSION_06_8X_MIN" == "y" ] ; then
	PVER="06_8X"
elif [ "$FREETZ_AVM_VERSION_06_5X_MIN" == "y" ] ; then
	PVER="06_5X"
fi

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/832-hide_dsl_overview-hint/832-hide_dsl_overview-hint_${PVER}.patch"

