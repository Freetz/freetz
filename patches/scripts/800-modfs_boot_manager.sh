[ "$FREETZ_PATCH_MODFS_BOOT_MANAGER" = "y" ] || return 0;

echo1 "adding modfs boot-manager"

system_reboot_lua_patch=$(mktemp -q -t "bootmanager_system_reboot_lua-XXXXXX.patch")
for oem in $(supported_brandings) all; do
	www_oem="${FILESYSTEM_MOD_DIR}/usr/www/${oem}"
	[ -d "${www_oem}" -a ! -L "${www_oem}" ] || continue

	echo2 "adding boot-manager front end to branding \"${oem}\""

	cat "${TOOLS_DIR}/yf/bootmanager/patch_system_reboot_lua.patch" \
	| sed -r -e 's,^(([+]{3}|-{3}) usr/www/)[^/]+/,\1'"${oem}"'/,' \
	> "${system_reboot_lua_patch}"

	modpatch "$FILESYSTEM_MOD_DIR" "${system_reboot_lua_patch}"
done
rm -f "${system_reboot_lua_patch}"

echo2 "adding boot-manager back end script"
cp -a "${TOOLS_DIR}/yf/bootmanager/gui_bootmanager" "${FILESYSTEM_MOD_DIR}/usr/bin/"
chmod 755 "${FILESYSTEM_MOD_DIR}/usr/bin/gui_bootmanager"
