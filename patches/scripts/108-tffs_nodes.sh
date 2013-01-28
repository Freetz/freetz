[ "$FREETZ_AVM_VERSION_05_2X_MIN" == "y" ] || return 0
echo1 "applying tffs_nodes patch"
# This creates the char device for saving Freetz "flash"

for f in S08-tffs S01-head; do
	grep -q '^tffs_nodes_list=""$' "${FILESYSTEM_MOD_DIR}/etc/init.d/$f" && break
	f=""
done
[ -z "$f" ] && error 1 "can't find suitable file for adding node"

modsed \
  's/\(tffs_nodes_list=\)""/\1"$((0x3C)),freetz"/' \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/$f" \
  '$((0x3C)),freetz'
