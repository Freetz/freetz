[ "$FREETZ_PACKAGE_E2FSPROGS_BLKID" == "y" -o "$FREETZ_BUSYBOX__KEEP_BINARIES" != "y" ] || return 0
echo1 "moving blkid around"

if [ -x "${FILESYSTEM_MOD_DIR}/usr/sbin/blkid" ]; then
	echo2 "moving AVM's blkid from /usr/sbin to /sbin"
	mv "${FILESYSTEM_MOD_DIR}/usr/sbin/blkid" "${FILESYSTEM_MOD_DIR}/sbin/"
	# symlink /sbin-version from /usr/sbin (AVM uses absolute /usr/sbin-path in some scripts)
	ln -sf ../../sbin/blkid "${FILESYSTEM_MOD_DIR}/usr/sbin/blkid"
fi

if [ -x "${FILESYSTEM_MOD_DIR}/sbin/blkid" ]; then
	echo2 "renaming AVM's blkid to blkid-avm"
	mv "${FILESYSTEM_MOD_DIR}/sbin/blkid" "${FILESYSTEM_MOD_DIR}/sbin/blkid-avm"
fi

get_preferred_blkid_version() {
	if [ "$FREETZ_PATCH_FREETZMOUNT" == "y" ]; then
		echo "blkid-busybox"
	elif [ "$FREETZ_AVM_HAS_E2FSPROGS" == "y" -a "$FREETZ_REMOVE_AVM_E2FSPROGS" != "y" ]; then
		echo "blkid-avm"
	elif [ "$FREETZ_PACKAGE_E2FSPROGS_BLKID" == "y" -a "$EXTERNAL_FREETZ_PACKAGE_E2FSPROGS_blkid" != "y" ]; then
		echo ""  # binary not renamed
	elif [ "$FREETZ_PACKAGE_UTIL_LINUX" == "y" -a "$EXTERNAL_FREETZ_PACKAGE_UTIL_LINUX" != "y" ]; then
		echo "blkid-util-linux"
	elif [ "$(eval echo "\$FREETZ_BUSYBOX___V$(echo ${FREETZ_BUSYBOX__VERSION_STRING/.} | head -c3)_BLKID")" == "y" ]; then
		echo "blkid-busybox"
	else
		echo ""  # no blkid installed
	fi
}

preferred_blkid_version=$(get_preferred_blkid_version)
if [ -n "$preferred_blkid_version" ]; then
	echo2 "symlinking blkid to $preferred_blkid_version"
	ln -sf "$preferred_blkid_version" "${FILESYSTEM_MOD_DIR}/sbin/blkid"
fi

