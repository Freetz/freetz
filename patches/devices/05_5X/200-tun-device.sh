# Create symlink for tun device
# Kernel version 2.6.28 creates device file in /dev
# and others in /dev/net.
if [ "$FREETZ_KERNEL_VERSION_2_6_28" == "y" ]; then
	modsed 's#^\(KERNEL=="tun".*\)#\1, SYMLINK+="net/tun"#' \
	  "${FILESYSTEM_MOD_DIR}/etc/udev/rules.d/50-udev-default.rules"
else
	modsed 's#^\(KERNEL=="tun".*\)#\1, SYMLINK+="tun"#' \
	  "${FILESYSTEM_MOD_DIR}/etc/udev/rules.d/50-udev-default.rules"
fi
