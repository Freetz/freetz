[ "$FREETZ_PACKAGE_ORANGEBOX" == "y" ] || return 0
echo1 "adding orangebox-lines to rc.S"
if [ "$FREETZ_TYPE_LABOR" == "y" ]; then
	if [ "$FREETZ_TYPE_LABOR_PHONE" == "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor_phone.patch
	elif [ "$FREETZ_TYPE_LABOR_DSL" == "y" ] || [ "$FREETZ_TYPE_LABOR_MINI" == "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor_dsl.patch
	elif [ "$FREETZ_TYPE_LABOR_BETA" == "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor_beta.patch
	elif  [ "$FREETZ_TYPE_LABOR_VPN" == "y" ]; then
	                modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor_vpn.patch
	else
		modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor.patch
	fi
elif [ "$FREETZ_TYPE_STRING" == "W900V" ]; then
	# kriegaex: This special patch used to be for W701V and W900V
	# (not W501V), but now the normal patch works again for W701V. So this
	# one here remains reserved for W900V, even though currently Orangebox
	# cannot be selected for any Speedport except W701V.
	# TODO(?): orangebox-enable the other two, if possible
	modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_speedport.patch
elif [ "$FREETZ_TYPE_STRING" == "7170" -o "$FREETZ_TYPE_STRING" == "7140" ] && [ "$FREETZ_TYPE_LANG_A_CH" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_a_ch.patch
elif [ "$FREETZ_TYPE_STRING" == "7170" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170.patch
else
	modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox.patch
fi

if [ "$FREETZ_PACKAGE_ORANGEBOX_TSB" == "y" ]; then
	sed -i -e "s/isTSB 0/isTSB 1/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi
if [ "$FREETZ_PACKAGE_WOL_CGI" == "y" ]; then
	sed -i -e "s/isWOL 0/isWOL 1/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

