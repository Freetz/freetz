if [ "$DS_PACKAGE_ORANGEBOX" == "y" ]; then
	echo1 "adding orangebox-lines to rc.S"
	if [ "$DS_TYPE_LABOR" == "y" ]; then
		if [ "$DS_TYPE_LABOR_PHONE" == "y" ] || [ "$DS_TYPE_LABOR_WLAN" == "y" ] || [ "$DS_TYPE_LABOR_DSL" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor_phone.patch
		else
			modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor.patch
		fi
	elif [ "${DS_TYPE_STRING/[79]0[01]/x0y}" == "Wx0yV" ]; then
		# kriegaex: At the time of writing this the patch would succeed for
		# W701V and W900V, but fail for W501V. The normal patch fits with an
		# offset for W501V, so it is excluded here. But Orangebox can only be
		# selected for W701V currently. Why this is so, I don't know.
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
