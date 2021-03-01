[ "$FREETZ_PATCH_UDEVMOUNT" == "y" ] || return 0
echo1 'adding udevmount'

MOUNTSD="${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-mount-sd"
STORAGE="${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

modsed "2i. /usr/lib/libmodudevm.sh" "$MOUNTSD"
modsed "2i. /usr/lib/libmodudevm.sh" "$STORAGE"

modsed "s/do_mount_locked *()/REAL__&/" "$MOUNTSD"
modsed "s/do_umount_locked *()/REAL__&/" "$MOUNTSD"
modsed "s/do_umount_locked *()/REAL__&/" "$STORAGE"

