[ "$FREETZ_PACKAGE_USBROOT" == "y" ] || return 0
echo1 "remove usb host stop from post_install"
modsed "/^.*usb.pandu stop$/ s/^/: #/g" "$VARTAR_MOD_DIR/var/post_install"
