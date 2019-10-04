STORAGE_FILE="${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

echo1 "fixing some typos in AVM storage/mount code"
# fix AVM typo, lsmod output is usb_storage
modsed "s/lsmod | grep usb-storage/lsmod | grep usb_storage/g" "${STORAGE_FILE}"
# fix AVM typo, remove '>' from 'mv -f $DEVMAP.$$ > $DEVMAP'
# affected versions: Fritz!OS 6.0x for 7240/7270v2/7270v3
modsed -r "s,^(mv -f [$]DEVMAP[.][$][$]) > ([$]DEVMAP)$,\1 \2," "${STORAGE_FILE}"

echo1 "applying some_maybe_removed_component"
# we might have removed some of the components, prepend corresponding msgsend's with [ -e "some_maybe_removed_component" ] && msgsend
if [ -e "${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-mount-sd" ]; then
	RUN_MOUNT_FILE="${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-mount-sd"
else
	RUN_MOUNT_FILE="${FILESYSTEM_MOD_DIR}/etc/hotplug/run_mount"
fi
for file in "${STORAGE_FILE}" "${RUN_MOUNT_FILE}"; do
	modsed -r 's,^([ \t]*)(msgsend.* ((libmediasrv|libcloudcds|libgpmsrv)[.]so) ),\1[ -e /lib/\3 ] \&\& \2,' "${file}"
	modsed -r 's,^([ \t]*)(msgsend.* (gpmdb) ),\1[ -e /sbin/\3 ] \&\& \2,' "${file}"
done

echo1 "preventing erase of storages"
# replace rm -rf $dir with rmdir $dir
# remove all lines with "chmod 000"
for file in \
  ${FILESYSTEM_MOD_DIR}/etc/init.d/S15-filesys \
  ${FILESYSTEM_MOD_DIR}/etc/hotplug/storage \
  ${FILESYSTEM_MOD_DIR}/etc/hotplug/run_mount \
  ${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-mount-sd \
  ; do
	[ -e "$file" ] || continue
	modsed 's/rm -rf /rmdir /g' "$file"
	modsed "/chmod 000.*$/d" "$file"
done

