if [ "$DS_PACKAGE_ORANGEBOX" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}adding orangebox-lines to rc.S"
	if [ $DS_TYPE_FON_WLAN_7170_LABOR ]
	then
	modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox_7170_labor.patch
	else
	modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox.patch
	fi
	if [ "$DS_PACKAGE_ORANGEBOX_TSB" == "y" ]
	then
	    sed -i -e "s/isTSB 0/isTSB 1/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	fi
	if [ "$DS_PACKAGE_WOL_CGI" == "y" ]
	then
	    sed -i -e "s/isWOL 0/isWOL 1/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	fi
fi
