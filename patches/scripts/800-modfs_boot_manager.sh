[ "$FREETZ_PATCH_MODFS_BOOT_MANAGER" = "y" ] || return 0;

echo1 "adding modfs boot-manager"
for step in precheck install postcheck; do
	TARGET_BRANDINGS=all \
	TARGET_BRANDING=all \
	source "${TOOLS_DIR}/modfs/modscripts/gui_boot_manager_v0.4" \
		en \
		"${FILESYSTEM_MOD_DIR}" \
		"MODE (UNUSED)" \
		"${step}"
	[ $? -eq 0 ] || error 1 "adding modfs boot-manager failed in step \"${step}\""
done

# replace modfs version of boot-manager with a more recent one from YourFritz project
cp -a "${TOOLS_DIR}/yf/bootmanager/gui_bootmanager" "${FILESYSTEM_MOD_DIR}/usr/bin/"
chmod 755 "${FILESYSTEM_MOD_DIR}/usr/bin/gui_bootmanager"
