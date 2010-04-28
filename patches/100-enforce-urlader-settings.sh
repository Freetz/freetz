if [ "$FREETZ_ENFORCE_URLADER_SETTINGS" = y ]; then
	echo enforce urlader settings

	mv "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S.orig"

	cat > "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S" << EOF
#!/bin/sh
mount -t proc proc /proc
EOF

	if [ -n "$FREETZ_ENFORCE_URLADER_SETTING_FIRMWARE_VERSION" ]; then
		echo 'firmware_version="$(echo $(grep firmware_version /proc/sys/urlader/environment) | cut -d' ' -f2)"'
		echo 'if [ "$firmware_version" != "'$FREETZ_ENFORCE_URLADER_SETTING_FIRMWARE_VERSION'" ]; then'
		echo 'echo firmware_version '$FREETZ_ENFORCE_URLADER_SETTING_FIRMWARE_VERSION' > /proc/sys/urlader/environment'
#		echo 'echo '$FREETZ_ENFORCE_URLADER_SETTING_FIRMWARE_VERSION' > /proc/sys/urlader/firmware_version'
		echo 'fi'
	fi >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	if [ -n "$FREETZ_ENFORCE_URLADER_SETTING_MY_IPADDRESS" ]; then
		echo 'my_ipaddress="$(echo $(grep my_ipaddress /proc/sys/urlader/environment) | cut -d' ' -f2)"'
		echo '[ "$my_ipaddress" = '$FREETZ_ENFORCE_URLADER_SETTING_MY_IPADDRESS' ] || echo my_ipaddress '$FREETZ_ENFORCE_URLADER_SETTING_MY_IPADDRESS' > /proc/sys/urlader/environment'
	fi >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	if [ -n "$FREETZ_ENFORCE_URLADER_SETTING_PRODUCTID" ]; then
		echo 'ProductID="$(echo $(grep ProductID /proc/sys/urlader/environment) | cut -d' ' -f2)"'
		echo '[ "$ProductID" = '$FREETZ_ENFORCE_URLADER_SETTING_PRODUCTID' ] || echo ProductID '$FREETZ_ENFORCE_URLADER_SETTING_PRODUCTID' > /proc/sys/urlader/environment'
	fi >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

	cat >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S" << EOF
umount /proc
EOF
	cat "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S.orig" >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	rm -f "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S.orig"
	chmod 755 "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi
