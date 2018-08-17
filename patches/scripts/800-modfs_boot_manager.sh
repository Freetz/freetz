[ "$FREETZ_PATCH_MODFS_BOOT_MANAGER" = "y" ] || return 0;

for oem in $(supported_brandings) all; do
	www_oem="${FILESYSTEM_MOD_DIR}/usr/www/${oem}"
	[ -d "${www_oem}" -a ! -L "${www_oem}" ] || continue

	echo1 "adding modfs boot-manager to branding \"${oem}\""
	for step in precheck install postcheck; do
		TARGET_BRANDINGS=${oem} \
		TARGET_BRANDING=${oem} \
		source "${TOOLS_DIR}/modfs/modscripts/gui_boot_manager_v0.4" \
			en \
			"${FILESYSTEM_MOD_DIR}" \
			"MODE (UNUSED)" \
			"${step}"
		[ $? -eq 0 ] || error 1 "adding modfs boot-manager failed in step \"${step}\""
	done
done

# replace modfs version of boot-manager with a more recent one from YourFritz project
cp -a "${TOOLS_DIR}/yf/bootmanager/gui_bootmanager" "${FILESYSTEM_MOD_DIR}/usr/bin/"
chmod 755 "${FILESYSTEM_MOD_DIR}/usr/bin/gui_bootmanager"
