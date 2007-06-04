if  [ "$DS_PATCH_ATA" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}applying ata patch"
	sed -i -e "s/ATA=n/ATA=y/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
fi
