[ "$FREETZ_HAS_AVM_CHRONYD" == "y" ] || return 0

if [ "$FREETZ_REMOVE_CHRONYD" == "y" ]; then 
	echo1 "remove chronyd files"
	rm_files "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.chrony" \
		"${FILESYSTEM_MOD_DIR}/etc/onlinechanged/chrony" \
		"${FILESYSTEM_MOD_DIR}/sbin/chronyc" \
		"${FILESYSTEM_MOD_DIR}/sbin/chronyd"
else
	[ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.rtc.sh" ] && \
		modsed "s#/var/dev/rtc#/dev/rtc#g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.rtc.sh"
fi
