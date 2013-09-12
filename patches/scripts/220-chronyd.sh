[ "$FREETZ_AVM_HAS_CHRONYD" == "y" ] || return 0

if [ "$FREETZ_REMOVE_CHRONYD" == "y" ]; then
	echo1 "remove chronyd files"
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.chrony" \
	  "${FILESYSTEM_MOD_DIR}/etc/onlinechanged/chrony" \
	  "${FILESYSTEM_MOD_DIR}/sbin/chronyc" \
	  "${FILESYSTEM_MOD_DIR}/sbin/chronyd"
	sedfile="${HTML_LANG_MOD_DIR}/net/network_settings.lua"
	if [ -e "$sedfile" ]; then
		# patcht Heimnetz > Netzwerk > Netzwerkeinstellungen > Zeitsynchronisation
		echo1 "patching ${sedfile##*/}"
		modsed '/"time:settings\/chrony_enabled"/d' $sedfile
		#g_var.time_enabled = box.query("time:settings/chrony_enabled") == "1"
		#cmtable.save_checkbox(ctlmgr_save, "time:settings/chrony_enabled" , "time_server_activ")
		modsed '/"time:settings\/ntp_server"/d' $sedfile
		#g_var.time_server = box.query("time:settings/ntp_server")
		#cmtable.add_var(ctlmgr_save, "time:settings/ntp_server" , box.post.time_server)
		modsed '/^not_empty(uiViewTimeServerList\/time_server, netset)$/d' $sedfile
		sedrows=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*{?859:445?}.*$/\1/p')
		sedrowe=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<div id="uiShowOtherIpv6Router">$/\1/p')
		modsed "$((sedrows+3)),$((sedrowe-1))d" $sedfile
	fi
else
	[ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.rtc.sh" ] && \
	  modsed "s#/var/dev/rtc#/dev/rtc#g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.rtc.sh"
fi
