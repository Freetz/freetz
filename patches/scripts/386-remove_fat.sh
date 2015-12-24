[ "$FREETZ_REMOVE_FAT" == "y" ] || return 0
echo1 "removing fat modules"
fskodir=${MODULES_DIR}/kernel/fs
for file in $(find $fskodir/fat/ $fskodir/vfat/ -name '*.ko' 2>/dev/null); do
	rm_files $file
done
