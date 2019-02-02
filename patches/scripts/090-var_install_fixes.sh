var_install_file="${FIRMWARE_MOD_DIR}/var/install"


if grep -q "bs=256 skip=1 conv=sync" "${var_install_file}" 2>/dev/null; then
	echo1 "removing unnecessary conv=sync option from dd call in /var/install"
	modsed -r 's,(bs=256 skip=1) conv=sync,\1,' "${var_install_file}"
fi

# fix 7390 reboot problem on module unload
modsed '/rmmod .*dect/d' "$VARTAR_MOD_DIR/var/post_install"

if grep -q "cannot mount squashfs, trying ext2" "${var_install_file}" 2>/dev/null; then
	echo1 "adding alternative offset-based ext2-mount-method (reduces memory footprint while flashing the firmware)"

modsed '/cannot mount squashfs, trying ext2/ a\
# Try mounting using the offset option (available only in Freetz) to reduce memory footprint, if it fails use AVMs dd-based method\
echo '"'"'    mount -t ext2 -o loop,offset=256 /var/tmp/filesystem.image /var/tmp/fs'"'"' >> /var/post_install\
echo '"'"'    if ! mount | grep -q "/var/tmp/fs type ext2" 2>/dev/null; then'"'"' >> /var/post_install' "${var_install_file}"

modsed '/mount -t ext2 \/var\/tmp\/fsimage.ext2/ a\
echo '"'"'    fi'"'"' >> /var/post_install' "${var_install_file}"

fi
