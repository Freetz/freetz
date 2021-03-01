[ "$FREETZ_AVM_VERSION_05_2X_MIN" == "y" ] || return 0
echo1 "creating symlink for tun device"

if [ "$FREETZ_KERNEL_VERSION_2_6_28" == "y" ]; then
	# creates device file in /dev
	modsed 's#^\(KERNEL=="tun".*\)#\1, SYMLINK+="net/tun"#' \
	  "${FILESYSTEM_MOD_DIR}/etc/udev/rules.d/50-udev-default.rules"
else
	# creates device file in /dev/net
	for file in \
	  etc/udev/rules.d/50-udev-default.rules \
	  lib/udev/rules.d/50-udev-default.rules \
	  ; do
		[ -e "${FILESYSTEM_MOD_DIR}/$file" ] || continue
		modsed 's#^\(KERNEL=="tun".*\)#\1, SYMLINK+="tun"#' \
		  "${FILESYSTEM_MOD_DIR}/$file"
	done
fi

