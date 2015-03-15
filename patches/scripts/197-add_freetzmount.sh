echo1 "applying 'remove components'-part of FREETZMOUNT patch"

STORAGE_FILE="${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"
if [ -e "${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-mount-sd" ]; then
	RUN_MOUNT_FILE="${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-mount-sd"
else
	RUN_MOUNT_FILE="${FILESYSTEM_MOD_DIR}/etc/hotplug/run_mount"
fi

# we might have removed some of the components, prepend corresponding msgsend's with [ -e "some_maybe_removed_component" ] && msgsend
for file in "${STORAGE_FILE}" "${RUN_MOUNT_FILE}"; do
	modsed -r 's,^([ \t]*)(msgsend.* ((libmediasrv|libcloudcds|libgpmsrv)[.]so) ),\1[ -e /lib/\3 ] \&\& \2,' "${file}"
	modsed -r 's,^([ \t]*)(msgsend.* (gpmdb) ),\1[ -e /sbin/\3 ] \&\& \2,' "${file}"
done

[ "$FREETZ_PATCH_FREETZMOUNT" == "y" ] || return 0
echo1 "applying FREETZMOUNT patch"

PATCHED_BY_FREETZ=" # patched by FREETZ"
SCRIPTPATCHER="${TOOLS_DIR}/scriptpatcher.sh"
RUN_LIBMODMOUNT="[ -x /usr/lib/libmodmount.sh ] && . /usr/lib/libmodmount.sh$PATCHED_BY_FREETZ"

# first of all old usbstorage stuff

# (filesystem) modules are loaded by modload
modsed 's/modprobe vfat//' "${STORAGE_FILE}"

# replace rm -rf $dir with rmdir $dir
# remove all lines with "chmod 000"
for file in "${STORAGE_FILE}" "${RUN_MOUNT_FILE}"; do
	modsed 's/rm -rf /rmdir /g' "${file}"
	modsed "/chmod 000.*$/d" "${file}"
done

# fix AVM typo, lsmod output is usb_storage
modsed "s/lsmod | grep usb-storage/lsmod | grep usb_storage/g" "${STORAGE_FILE}"

# and now the new patching of /etc/hotplug/storage and /etc/hotplug/run_mount

echo2 "patching run_mount script"
${SCRIPTPATCHER} -fri ${RUN_MOUNT_FILE} -s "nicename" -o ${RUN_MOUNT_FILE} -n "$RUN_LIBMODMOUNT" # replace nicename()
${SCRIPTPATCHER} -fdi ${RUN_MOUNT_FILE} -s "do_mount" -o ${RUN_MOUNT_FILE} # delete do_mount()
${SCRIPTPATCHER} -fdi ${RUN_MOUNT_FILE} -s "do_mount_locked" -o ${RUN_MOUNT_FILE} # delete do_mount_locked() 7320
${SCRIPTPATCHER} -fdi ${RUN_MOUNT_FILE} -s "do_umount_locked" -o ${RUN_MOUNT_FILE} # delete do_umount_locked() 7320

echo2 "patching /etc/hotplug/storage"
${SCRIPTPATCHER} -fdi ${STORAGE_FILE} -s "do_umount_locked" -o ${STORAGE_FILE} # delete do_umount_locked()
${SCRIPTPATCHER} -fri ${STORAGE_FILE} -s "do_umount" -o ${STORAGE_FILE} -n "$RUN_LIBMODMOUNT" # replace do_umount()
${SCRIPTPATCHER} -fdi ${STORAGE_FILE} -s "hd_spindown_control" -o ${STORAGE_FILE} # delete hd_spindown_control()
${SCRIPTPATCHER} -tri ${STORAGE_FILE} -s "reload" -o ${STORAGE_FILE} -n "reload)$PATCHED_BY_FREETZ\nstorage_reload$PATCHED_BY_FREETZ\n;;" # replace case section reload)
if [ "$FREETZ_AVM_VERSION_05_2X_MAX" == "y" ]; then
${SCRIPTPATCHER} -tri ${STORAGE_FILE} -s "unplug" -o ${STORAGE_FILE} -n "unplug)$PATCHED_BY_FREETZ\nstorage_unplug "'$'"* $PATCHED_BY_FREETZ\n;;" # replace case section unplug)
else
modsed '/umount_usb)/ i \
unplug)'"$PATCHED_BY_FREETZ"'\
storage_unplug $*'"$PATCHED_BY_FREETZ"'\
;;' ${STORAGE_FILE}
fi
modsed "/remove)/a remove_swap "'$'"*$PATCHED_BY_FREETZ" ${STORAGE_FILE} # add removing of swap partitions to section remove)
