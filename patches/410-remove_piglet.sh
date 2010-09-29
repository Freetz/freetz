isFreetzType 7170 && [ "$FREETZ_REMOVE_PIGLET_V1" == "y" -o "$FREETZ_REMOVE_PIGLET_V2" == "y" ] || return 0
echo1 "removing 7170 piglet file(s)"

bitfile_path="${FILESYSTEM_MOD_DIR}/lib/modules"
bitfile_name="microvoip_isdn_top.bit"

files=""
[ "$FREETZ_REMOVE_PIGLET_V1" == "y" ] && files+="${bitfile_path}/${bitfile_name}"
[ "$FREETZ_REMOVE_PIGLET_V2" == "y" ] && files+=" ${bitfile_path}/${bitfile_name}1"

rm_files "$files"
