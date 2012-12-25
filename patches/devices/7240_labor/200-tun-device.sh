# Create symlink for tun device under /dev/net/tun
modsed 's#^\(KERNEL=="tun".*\)#\1, SYMLINK+="net/tun"#' \
	"${FILESYSTEM_MOD_DIR}/etc/udev/rules.d/50-udev-default.rules"
