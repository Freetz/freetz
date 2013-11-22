[ "$FREETZ_PACKAGE_USBROOT" == "y" ] || return 0

echo1 "remove usb host stop from post_install"
modsed "/^.*usb.pandu stop$/ s/^/: #/g" "$VARTAR_MOD_DIR/var/post_install"
modsed "/^.*usb.pandu stop$/ s/^/: #/g" "$FILESYSTEM_MOD_DIR/bin/prepare_fwupgrade"

usb_init_file="${FILESYSTEM_MOD_DIR}/etc/init.d/S46-usb"

[ -x "$usb_init_file" ] || return 0

cat << EOF >> "$usb_init_file"

###########################
####  Freetz  USBROOT  ####
###########################
if [ "\$(/etc/init.d/rc.usbroot status)" = "running" ]; then
	if [ -n "\$(which udevd)" ]; then
		# This box employs the udevd, tell it about the
		# missed "USB disk device plugged in" events.
		echo "*** USBROOT: Recreating USB disk devices. ***"
		device="\$(/etc/init.d/rc.usbroot store)"
		device="\${device%%:*}"
		device="\${device##*/}"
		for path in /sys/block/sd[a-z] /sys/block/sd[a-z]/sd[a-z][0-9]; do
			# add device only if it is not the usb root device
			# so it is not mounted one more time
			[ "\${path##*/}" = "\$device" ] || echo add > \$path/uevent
		done
	fi
fi

EOF
