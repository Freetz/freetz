[ "$FREETZ_PATCH_MAXDEVCOUNT" == "y" ] || return 0
#if isFreetzType 3270 3270_V3 3370 6840 7320 7240 7270_16 7330 7340 7390; then
if [ -e "${FILESYSTEM_MOD_DIR}/etc/hotplug/create_handle.sh" ]; then
	file="create_handle.sh"
else
	file="usb.pandu"
fi
echo1 "patching ${file}: MAXDEVCOUNT"
modsed "s/^MAXDEVCOUNT=/MAXDEVCOUNT=9	# oldvalue: /g" \
 "${FILESYSTEM_MOD_DIR}/etc/hotplug/${file}" \
 "^MAXDEVCOUNT=9"
