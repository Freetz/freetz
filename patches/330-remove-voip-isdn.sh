[ "$FREETZ_REMOVE_VOIP_ISDN" == "y" ] || return 0

echo1 "removing VoIP & ISDN files"
if [ "$FREETZ_HAS_USB_HOST" == "y" ]; then 
rm_files $(find ${FILESYSTEM_MOD_DIR} ! -path '*/lib/*' -a -name '*isdn*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	 $(find ${FILESYSTEM_MOD_DIR}/lib/modules/2.6*/ -name '*isdn*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	 $(find ${FILESYSTEM_MOD_DIR} ! -path '*/lib/*' -a -name '*voip*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/')
else
rm_files $(find ${FILESYSTEM_MOD_DIR} -name '*isdn*' -o -name '*iglet*' -o -name '*voip' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/')
fi

rm_files $(find ${FILESYSTEM_MOD_DIR} -name '*capi*' -o -name '*tam*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	 $(find ${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr -name 'libfon*' -o -name 'libtelcfg*')
