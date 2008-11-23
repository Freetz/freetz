[ "$FREETZ_PACKAGE_MDEV" == "y" ] || return 0

ln_file () {
	echo2 "linking $2 to $1"
	ln -s "$1" "$2"
}

echo1 "relocating stick'n'surf configuration program"
mkdir -m 750 -p ${FILESYSTEM_MOD_DIR}/lib/mdev/misc
mv ${FILESYSTEM_MOD_DIR}/etc/hotplug/avmusbwlanstart ${FILESYSTEM_MOD_DIR}/lib/mdev/misc
chmod 750 ${FILESYSTEM_MOD_DIR}/lib/mdev/misc/avmusbwlanstart

# remove original hotplug system
echo1 "removing original hotplug subsystem"
rm_files "$(find ${FILESYSTEM_MOD_DIR}/etc/hotplug -depth ! -name hotplug)"
rm_files "${FILESYSTEM_MOD_DIR}/etc/hotplug"
mkdir ${FILESYSTEM_MOD_DIR}/var/media

# 
echo1 "setup mdev boot sequence"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/mdev_fstab.patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/mdev_rc.S.patch"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/init-syslog.patch"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/mdev_debug_rc.S.patch"

# patch avm scripts for new system
echo1 "setup new hotplug system"
ln_file var/media "${FILESYSTEM_MOD_DIR}/media"
ln_file ../lib/mdev/interface "${FILESYSTEM_MOD_DIR}/etc/hotplug"

echo1 "applying usb wlan configuration change patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/mdev_wlancfgchanged.patch"

echo1 "applying usb prepare fwupgrade patch"
sed -i -e "s/usb.pandu/storage/g" "${FILESYSTEM_MOD_DIR}/bin/prepare_fwupgrade"


echo1 "applying usb post_install patch"
modpatch "$VARTAR_MOD_DIR" "${PATCHES_DIR}/cond/mdev_post_install.patch"

echo1 "set up local fstab"
modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR/cond/mdev_my_uuid.patch"

#echo1 "altering avm samba interface"
#rm_files "${FILESYSTEM_MOD_DIR}/etc/samba_control"
#ln_file ../lib/mdev/session/smbd "${FILESYSTEM_MOD_DIR}/etc/samba_control"
