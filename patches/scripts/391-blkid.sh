if [ -x "${FILESYSTEM_MOD_DIR}/usr/sbin/blkid" ]; then
	echo1 "moving AVM's blkid from /usr/sbin to /sbin"
	mv "${FILESYSTEM_MOD_DIR}/usr/sbin/blkid" "${FILESYSTEM_MOD_DIR}/sbin/"
	# symlink /sbin-version from /usr/sbin (AVM uses absolute /usr/sbin-path in some scripts)
	ln -sf ../../sbin/blkid "${FILESYSTEM_MOD_DIR}/usr/sbin/blkid"
fi

if [ -x "${FILESYSTEM_MOD_DIR}/sbin/blkid" ]; then
	echo1 "renaming AVM's blkid to blkid-avm"
	mv "${FILESYSTEM_MOD_DIR}/sbin/blkid" "${FILESYSTEM_MOD_DIR}/sbin/blkid-avm"
fi

get_preferred_blkid_version() {
	if [ "$FREETZ_PACKAGE_UTIL_LINUX" == "y" -a "$EXTERNAL_FREETZ_PACKAGE_UTIL_LINUX" != "y" ]; then
		echo "blkid-util-linux"
	else
		if [ "$FREETZ_PATCH_FREETZMOUNT" != "y " ]; then
			if [ -x "${FILESYSTEM_MOD_DIR}/sbin/blkid-avm" ]; then
				echo "blkid-avm"
			elif [ "$FREETZ_BUSYBOX_BLKID" == "y" ]; then
				echo "blkid-busybox"
			fi
		else
			if [ "$FREETZ_BUSYBOX_BLKID" == "y" ]; then
				echo "blkid-busybox"
			elif [ -x "${FILESYSTEM_MOD_DIR}/sbin/blkid-avm" ]; then
				echo "blkid-avm"
			fi
		fi
	fi
}

preferred_blkid_version=$(get_preferred_blkid_version)
if [ -n "$preferred_blkid_version" ]; then
	echo1 "symlinking blkid to $preferred_blkid_version"
	ln -sf "$preferred_blkid_version" "${FILESYSTEM_MOD_DIR}/sbin/blkid"
fi
