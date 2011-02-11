[ "$FREETZ_PATCH_ATA" == "y" ] || return 0
echo1 "applying ata patch"
if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init" ]; then
	modsed "s/ATA=n/ATA=y/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
	modsed "s/isAta 0/isAta 1/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
else
	modsed "s/CONFIG_ATA=n/CONFIG_ATA=y/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi


