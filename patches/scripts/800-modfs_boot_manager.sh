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
