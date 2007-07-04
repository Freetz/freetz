if [ "$DS_PACKAGE_ORANGEBOX" == "y" ]; then
	echo1 "adding orangebox-lines to rc.S"
	if [ "$DS_TYPE_LABOR" == "y" ] && ! [ "$DS_TYPE_LABOR_WLAN" == "y" ]; then
		if [ "$DS_TYPE_LABOR_PHONE" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor_phone.patch
		else
			modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor.patch
		fi
	elif [ "${DS_TYPE_STRING/[579]0[01]/x0y}" == "Wx0yV" ]; then
		# kriegaex: At the time of writing this the patch would succeed for
		# W701V and W900V, but fail for W501V. But Orangebox can only can be
		# selected for W701V anyway. Why this is so, I don't know.
		# TODO(?): orangebox-enable the other two and then split the patch
		# again for W501V or make one for each box.
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
