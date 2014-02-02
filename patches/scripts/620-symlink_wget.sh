[ "$FREETZ_BUSYBOX_WGET" == "y" -o "$FREETZ_PACKAGE_WGET" == "y" ] || return 0

[ "$FREETZ_PACKAGE_WGET" == "y" -a "$FREETZ_WGET_ALWAYS_AVAILABLE" != "y" ] && WGET_POINTS_TO="wget-gnu" || WGET_POINTS_TO="wget-busybox"
echo1 "symlinking wget to $WGET_POINTS_TO"
ln -sf "$WGET_POINTS_TO" "${FILESYSTEM_MOD_DIR}/usr/bin/wget"
