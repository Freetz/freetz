[ "$FREETZ_PATCH_MODFS_BOOT_MANAGER" = "y" ] || return 0;

echo1 "adding modfs boot-manager"

TEMPDIR=$(mktemp -d)

for oem in $(supported_brandings) all; do
	www_oem="${FILESYSTEM_MOD_DIR}/usr/www/${oem}"
	[ -d "${www_oem}" -a ! -L "${www_oem}" ] || continue

	echo2 "adding boot-manager front end to branding \"${oem}\""

	TARGET_BRANDING="${oem}" \
	TARGET_SYSTEM_VERSION="autodetect" \
	TARGET_SYSTEM_VERSION_DETECTOR="${TOOLS_DIR}/yf/bootmanager/extract_version_values" \
	TARGET_DIR="${FILESYSTEM_MOD_DIR}" \
	TMP="$TEMPDIR" \
	sh "${TOOLS_DIR}/yf/bootmanager/add_to_system_reboot.sh"
done

rmdir "$TEMPDIR"

echo2 "adding boot-manager back end script"
cp -a "${TOOLS_DIR}/yf/bootmanager/gui_bootmanager" "${FILESYSTEM_MOD_DIR}/usr/bin/"
chmod 755 "${FILESYSTEM_MOD_DIR}/usr/bin/gui_bootmanager"
