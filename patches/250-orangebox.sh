if [ "$DS_PACKAGE_ORANGEBOX" == "y" ]; then
	echo1 "adding orangebox-lines to rc.S"
	if [ "$DS_TYPE_LABOR" == "y" ]; then
		if [ "$DS_TYPE_LABOR_PHONE" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor_phone.patch
		elif [ "$DS_TYPE_LABOR_DSL" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor_dsl.patch
		else
			modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor.patch
		fi
	elif [ "$DS_TYPE_STRING" == "W900V" ]; then
		# kriegaex: This special patch used to be for W701V and W900V
		# (not W501V), but now the normal patch works again for W701V. So this
		# one here remains reserved for W900V, even though currently Orangebox
		# cannot be selected for any Speedport except W701V.
		# TODO(?): orangebox-enable the other two, if possible
		modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_speedport.patch
	else
		modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox.patch
	fi

	if [ "$DS_PACKAGE_ORANGEBOX_TSB" == "y" ]; then
		sed -i -e "s/isTSB 0/isTSB 1/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	fi
	if [ "$DS_PACKAGE_WOL_CGI" == "y" ]; then
		sed -i -e "s/isWOL 0/isWOL 1/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	fi
fi
