[ "$FREETZ_PACKAGE_MDEV" == "y" ] || return 0

ln_file () {
	echo2 "linking $2 to $1"
	ln -s "$1" "$2"
}

echo1 "relocating stick'n'surf configuration program"
mkdir -m 750 -p ${FILESYSTEM_MOD_DIR}/lib/mdev/misc

if [ -e ${FILESYSTEM_MOD_DIR}/etc/hotplug/avmusbwlanstart ]; then
	mv ${FILESYSTEM_MOD_DIR}/etc/hotplug/avmusbwlanstart ${FILESYSTEM_MOD_DIR}/lib/mdev/misc
	chmod 750 ${FILESYSTEM_MOD_DIR}/lib/mdev/misc/avmusbwlanstart
else
	mv ${FILESYSTEM_MOD_DIR}/sbin/avmstickandsurf ${FILESYSTEM_MOD_DIR}/lib/mdev/misc/avmusbwlanstart
	chmod 750 ${FILESYSTEM_MOD_DIR}/lib/mdev/misc/avmusbwlanstart
fi

# remove original hotplug system
echo1 "removing original hotplug subsystem"
rm_files "$(find ${FILESYSTEM_MOD_DIR}/etc/hotplug -depth ! -name hotplug)"
rm_files "${FILESYSTEM_MOD_DIR}/etc/hotplug"
mkdir ${FILESYSTEM_MOD_DIR}/var/media

#
echo1 "setup mdev boot sequence"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/mdev_fstab.patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/mdev_rc.S.patch"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/init-syslog.patch"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/mdev_debug_rc.S.patch"

# patch avm scripts for new system
echo1 "setup new hotplug system"
ln_file var/media "${FILESYSTEM_MOD_DIR}/media"
ln_file ../lib/mdev/interface "${FILESYSTEM_MOD_DIR}/etc/hotplug"

echo1 "applying usb wlan configuration change patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/mdev_wlancfgchanged.patch"

echo1 "applying usb prepare fwupgrade patch"
modsed "s/usb.pandu/storage/g" "${FILESYSTEM_MOD_DIR}/bin/prepare_fwupgrade"

echo1 "applying usb post_install patch"
if isFreetzType 7170; then
	modpatch "$VARTAR_MOD_DIR" "${PATCHES_COND_DIR}/mdev_post_install_7170.patch"
else
	modpatch "$VARTAR_MOD_DIR" "${PATCHES_COND_DIR}/mdev_post_install_7270.patch"
fi

echo1 "set up local fstab"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/mdev_my_uuid.patch"

#echo1 "altering avm samba interface"
#rm_files "${FILESYSTEM_MOD_DIR}/etc/samba_control"
#ln_file ../lib/mdev/session/smbd "${FILESYSTEM_MOD_DIR}/etc/samba_control"
