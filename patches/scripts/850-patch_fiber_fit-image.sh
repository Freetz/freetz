[ "$FREETZ_TYPE_FIBER" == "y" ] || return 0
[ -e "${FILESYSTEM_MOD_DIR}/bin/upx-hwk-boot-prx" ] || return 0
echo1 "patching fiber fit-image"
# Hawkeye of 5590 gets a full fit-image to boot via ftp
# the 2nd bootloader is checking it and refuses to boot
# Workaround:
# A unmodified fit-image has to be placed on the storage

dev_path='dev_path=/var/media/ftp/fit-image/${CONFIG_VERSION//\./-}-$(/etc/version --project 2>/dev/null).fit'
modsed \
  "s,^dev_path=.*,$dev_path," \
  "${FILESYSTEM_MOD_DIR}/bin/upx-hwk-boot-prx" \
  "^$dev_path$"

