[ "$FREETZ_PATCH_MAXDEVCOUNT" == "y" ] || return 0
echo1 "patching usb.pandu: MAXDEVCOUNT"
sed -i -e "s/^MAXDEVCOUNT=/MAXDEVCOUNT=9	# oldvalue: /g" "${FILESYSTEM_MOD_DIR}/etc/hotplug/usb.pandu"
