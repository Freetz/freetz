[ "$FREETZ_TYPE_FIBER" == "y" ] || return 0
[ -e "${FILESYSTEM_MOD_DIR}/bin/upx-hwk-boot-prx" ] || return 0
echo1 "patching fiber fit-image"
# Hawkeye of 5590 gets a full fit-image to boot via ftp
# ar7-lite and/or the 2nd eva are checking the signature
# Someone should add a ftp command to freetz and checkt it
# Workaround:
# A unmodified fit-image has to be placed in the internal storage

dev_path='dev_path=/var/media/ftp/fit-image'
modsed \
  "s,^dev_path=.*,$dev_path," \
  "${FILESYSTEM_MOD_DIR}/bin/upx-hwk-boot-prx" \
  "^$dev_path$"

