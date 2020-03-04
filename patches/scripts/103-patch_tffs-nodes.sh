[ "$FREETZ_AVM_VERSION_05_2X_MIN" == "y" ] || return 0
echo1 "applying tffs_nodes patch"
# This creates the char device for saving Freetz "flash"

for f in \
  etc/init.d/S08-tffs \
  etc/init.d/S01-head \
  etc/init.d/rc.tffs.sh \
  etc/boot.d/rc.conf \
  etc/boot.d/core/tffs \
  ; do
	grep -q '^tffs_nodes_list=""$' "${FILESYSTEM_MOD_DIR}/$f" 2>/dev/null && break
	f=""
done
[ -z "$f" ] && error 1 "can't find suitable file for adding node"

modsed \
  's/\(tffs_nodes_list=\)""/\1"$((0x3C)),freetz"/' \
  "${FILESYSTEM_MOD_DIR}/$f" \
  '$((0x3C)),freetz'
