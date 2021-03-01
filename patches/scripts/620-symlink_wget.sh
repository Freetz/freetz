[ "$FREETZ_BUSYBOX_WGET" == "y" -o "$FREETZ_PACKAGE_WGET" == "y" ] || return 0
echo1 "moving wget around"

[ "$FREETZ_PACKAGE_WGET" == "y" -a "$FREETZ_WGET_ALWAYS_AVAILABLE" != "y" ] && WGET_POINTS_TO="wget-gnu" || WGET_POINTS_TO="wget-busybox"
[ "$FREETZ_BUSYBOX_WGET" == "y" -a "$FREETZ_PACKAGE_WGET" != "y" ] && WGET_POINTS_TO="wget-busybox"
[ "$FREETZ_BUSYBOX_WGET" != "y" -a "$FREETZ_PACKAGE_WGET" == "y" ] && WGET_POINTS_TO="wget-gnu"

echo2 "symlinking wget to $WGET_POINTS_TO"
ln -sf "$WGET_POINTS_TO" "${FILESYSTEM_MOD_DIR}/usr/bin/wget"

