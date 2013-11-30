
# if nas, mediaserv und samba are removed -> remove_nas deletes menu item Heimnetz > Speicher (NAS)

# AVM scripts should not kill Freetz Samba
if [ "$FREETZ_AVM_HAS_USB_HOST" == "y" -a "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" ]; then
	sed -i -e "/killall smbd*$/d" -e "s/pidof smbd/pidof/g" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"
fi

# remove AVM's specific samba files
if [ "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" -o "$FREETZ_REMOVE_SAMBA" == "y" ]; then
	echo1 "remove AVM samba config"
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/bin/inetdsamba" \
	  "${FILESYSTEM_MOD_DIR}/sbin/samba_config_gen" \
	  "${FILESYSTEM_MOD_DIR}/etc/samba_config.tar" \
	  "${FILESYSTEM_MOD_DIR}/lib/libsamba.so"

	echo1 "patching rc.net: renaming sambastart()"
	modsed 's/^\(sambastart *()\)/\1{ return; }\n_\1/' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"

	# patcht Heimnetz > Speicher (NAS)
	sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
	if [ -e "$sedfile" ]; then
		echo1 "patching ${sedfile##*/}"
		sedrows=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<div id="uiViewHomeSharing">.*$/\1/p')
		sedrowe=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*write_html_msg(g_val, "uiViewWorkgroup").*$/\1/p')
		[ -n "$sedrows" ] && modsed "$((sedrows)),$((sedrowe+2))d" $sedfile
		# disable value checking
		modsed '/uiViewShareName/d;/uiViewWorkgroup/d' $sedfile
		# disable value saving
		modsed '/ctlusb.settings.fritznas_share.*/d;/ctlusb.settings.samba-workgroup/d' $sedfile
	fi

	echo1 "patching rc.conf"
	modsed "s/CONFIG_SAMBA=.*$/CONFIG_SAMBA=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi

# no need  for AVM's or Freetz's nmbd
if [ "$FREETZ_REMOVE_SAMBA" == "y" ] || \
  [ "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" -a "$FREETZ_PACKAGE_SAMBA_NMBD" != "y" ]; then
	echo1 "remove AVM's nmbd"
	rm_files "${FILESYSTEM_MOD_DIR}/sbin/nmbd"
fi

# no need  for AVM's or Freetz's smbd
if [ "$FREETZ_REMOVE_SAMBA" == "y" ]; then
	echo1 "remove AVM samba files"
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/etc/samba_control" \
	  "${FILESYSTEM_MOD_DIR}/sbin/smbd" \
	  "${FILESYSTEM_MOD_DIR}/sbin/smbpasswd"
fi
