if [ "$DS_PACKAGE_ORANGEBOX" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}adding orangebox-lines to rc.S"
	modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/orangebox.patch
	if [ "$DS_PACKAGE_ORANGEBOX_TSB" == "y" ]
	then
	    sed -i -e "s/isTSB 0/isTSB 1/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	fi
	if [ "$DS_PACKAGE_ORANGEBOX_CALLPATCH" == "y" ]
	then
	    sed -i -e "s/isCallPatch 0/isCallPatch 1/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	fi
fi
