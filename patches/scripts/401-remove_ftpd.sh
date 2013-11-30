[ "$FREETZ_REMOVE_FTPD" == "y" -o "$FREETZ_AVM_HAS_NAS" == "y" ] || return 0

if [ "$FREETZ_AVM_HAS_NAS" == "y" -a "$FREETZ_REMOVE_FTPD" != "y" ]; then
	echo1 "remove banner from AVM ftpd"
	perl -pi -e 's#/etc/motd#/etc/fooo#g' "${FILESYSTEM_MOD_DIR}/sbin/ftpd"
fi

if [ "$FREETZ_REMOVE_FTPD" == "y" ]; then
	echo1 "remove AVM-ftpd files"
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/sbin/ftpd" \
	  "${FILESYSTEM_MOD_DIR}/bin/inetdftp" \
	  "${FILESYSTEM_MOD_DIR}/etc/ftpd_control"

	echo1 "patching rc.conf"
	modsed "s/CONFIG_FTP=.*$/CONFIG_FTP=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

	# patcht Heimnetz > Speicher (NAS)
	sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
	if [ -e "$sedfile" ]; then
		echo1 "patching ${sedfile##*/}"
		# entfernt "Speicher fuer Benutzer aus dem Internet freigeben" (04.xx)
		sedrows=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<div id="uiViewInternetSharingBox".*$/\1/p')
		sedrowe=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<div id="uiViewUseMusikBox".*$/\1/p')
		[ -n "$sedrows" ] && modsed "$((sedrows)),$((sedrowe-2))d" $sedfile
	fi

	return 0
fi
