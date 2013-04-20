[ "$FREETZ_REMOVE_PIGLET_POTS" == "y" -o \
  "$FREETZ_REMOVE_PIGLET_ISDN" == "y" -o \
  "$FREETZ_REMOVE_PIGLET_V1" == "y" -o \
  "$FREETZ_REMOVE_PIGLET_V2" == "y" ] || return 0
echo1 "removing unneeded piglet file(s)"

bitfile_path="${FILESYSTEM_MOD_DIR}/lib/modules"
files=""
if [ "$FREETZ_REMOVE_PIGLET_POTS" == "y" ]; then
	files+="${bitfile_path}/microvoip_top.bit "
	files+="${bitfile_path}/bitfile_pots.bit "
#	files+="${bitfile_path}/bitfile_pots.bit1 "
	modsed "s/piglet_bitfilemode=\`\/bin.*$/piglet_bitfilemode=1/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

if [ "$FREETZ_REMOVE_PIGLET_ISDN" == "y" ]; then
	files+="${bitfile_path}/microvoip_isdn_top.bit "
	files+="${bitfile_path}/microvoip_isdn_top.bit1 "
	files+="${bitfile_path}/bitfile_isdn.bit "
#	files+="${bitfile_path}/bitfile_isdn.bit1 "
	modsed "s/piglet_bitfilemode=\`\/bin.*$/piglet_bitfilemode=2/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

if [ "$FREETZ_REMOVE_PIGLET_V1" == "y" ]; then
	files+="${bitfile_path}/microvoip_isdn_top.bit "
	files+="${bitfile_path}/bitfile_isdn.bit "
	files+="${bitfile_path}/bitfile_pots.bit "
fi

if [ "$FREETZ_REMOVE_PIGLET_V2" == "y" ]; then
	files+="${bitfile_path}/microvoip_isdn_top.bit1 "
#	files+="${bitfile_path}/bitfile_isdn.bit1 "
#	files+="${bitfile_path}/bitfile_pots.bit1 "
fi

rm_files "$files"
