[ "$FREETZ_PATCH_MAXDEVCOUNT" == "y" ] || return 0
if isFreetzType 7320 || ( isFreetzType 7270 7390 && isFreetzType LABOR_PREVIEW); then
	file="create_handle.sh"
else
	file="usb.pandu"
fi
echo1 "patching ${file}: MAXDEVCOUNT"
modsed "s/^MAXDEVCOUNT=/MAXDEVCOUNT=9	# oldvalue: /g" "${FILESYSTEM_MOD_DIR}/etc/hotplug/${file}"
