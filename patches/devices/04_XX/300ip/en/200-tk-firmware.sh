# linking tcom-defaults to box-defaults 
ln -sf default.Fritz_Box_FON  "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_Eumex300IP"

# patch install script to accept firmware from FBF or Eumex
echo2 "applying install patch"
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/100-aliens/install/install-300ip-as-fon_en.patch" || exit 2

