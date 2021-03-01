[ "$FREETZ_PATCH_MAXDEVCOUNT" == "y" ] || return 0
echo1 "patching MAXDEVCOUNT"

[ -e "${FILESYSTEM_MOD_DIR}/etc/hotplug/create_handle.sh" ] && file="create_handle.sh" || file="usb.pandu"
modsed "s/^MAXDEVCOUNT=/MAXDEVCOUNT=9	# oldvalue: /g" \
  "${FILESYSTEM_MOD_DIR}/etc/hotplug/${file}" \
  "^MAXDEVCOUNT=9"

