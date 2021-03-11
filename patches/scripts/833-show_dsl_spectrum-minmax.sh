[ "$FREETZ_MODIFY_DSL_SPECTRUM" == "y" ] || return 0
echo1 "patching dsl spectrum"

if [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] ; then
	PVER="07_0X"
elif [ "$FREETZ_AVM_VERSION_06_8X_MIN" == "y" ] ; then
	PVER="06_8X"
elif [ "$FREETZ_AVM_VERSION_06_5X_MIN" == "y" ] ; then
	PVER="06_5X"
fi

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/833-show_dsl_spectrum-minmax/833-show_dsl_spectrum-minmax_${PVER}.patch"

