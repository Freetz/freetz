[ "$FREETZ_PATCH_FREETZMOUNT" == "y" ] || return 0
echo1 "applying FREETZMOUNT patch"

# first of all old usbstorage stuff

# load ext2 and ext3 modules
modsed '/modprobe vfat/a \
modprobe ext2 \
modprobe ext3 \
modprobe reiserfs' "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

# replace rm -rf $dir with rmdir $dir
sed -i 's/rm -rf /rmdir /g' "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage" \
	"${FILESYSTEM_MOD_DIR}/etc/hotplug/run_mount"

# remove all lines with "chmod 000"
modsed "/chmod 000.*$/d" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

# fix AVM typo, lsmod output is usb_storage
modsed "s/lsmod | grep usb-storage/lsmod | grep usb_storage/g" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

# and now the new patching of /etc/hotplug/storage and /etc/hotplug/run_mount

PATCHED_BY_FREETZ=" # patched by FREETZ"
SCRIPTPATCHER="${TOOLS_DIR}/scriptpatcher.sh"
STORAGE_FILE="${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"
RUN_MOUNT_FILE="${FILESYSTEM_MOD_DIR}/etc/hotplug/run_mount"
RUN_LIBMODMOUNT="[ -x /usr/lib/libmodmount.sh ] && . /usr/lib/libmodmount.sh$PATCHED_BY_FREETZ"

echo2 "patching /etc/hotplug/run_mount"
${SCRIPTPATCHER} -fri ${RUN_MOUNT_FILE} -s "nicename" -o ${RUN_MOUNT_FILE} -n "$RUN_LIBMODMOUNT" # replace nicename()
${SCRIPTPATCHER} -fdi ${RUN_MOUNT_FILE} -s "do_mount" -o ${RUN_MOUNT_FILE} # delete do_mount()

echo2 "patching /etc/hotplug/storage"
${SCRIPTPATCHER} -fri ${STORAGE_FILE} -s "do_umount" -o ${STORAGE_FILE} -n "$RUN_LIBMODMOUNT" # replace do_umount()
${SCRIPTPATCHER} -fdi ${STORAGE_FILE} -s "hd_spindown_control" -o ${STORAGE_FILE} # delete hd_spindown_control()
${SCRIPTPATCHER} -tri ${STORAGE_FILE} -s "reload" -o ${STORAGE_FILE} -n "reload)$PATCHED_BY_FREETZ\nstorage_reload$PATCHED_BY_FREETZ\n;;" # replace case section reload)
${SCRIPTPATCHER} -tri ${STORAGE_FILE} -s "unplug" -o ${STORAGE_FILE} -n "unplug)$PATCHED_BY_FREETZ\nstorage_unplug "'$'"* $PATCHED_BY_FREETZ\n;;" # replace case section unplug)
