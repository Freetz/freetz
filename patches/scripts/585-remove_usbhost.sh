[ "$FREETZ_REMOVE_USBHOST" = "y" ] || return 0

echo1 "removing USB Host"
rm_files "${MODULES_DIR}/kernel/drivers/usb/ahci/usbahcicore.ko"
rm_files "${MODULES_DIR}/kernel/drivers/usb/core/usbcore.ko"
rm_files "${MODULES_DIR}/kernel/drivers/usb/misc/usbauth/usbauth.ko"
rm_files "${MODULES_DIR}/kernel/drivers/usb/storage/usb-storage.ko"
rm_files "${MODULES_DIR}/kernel/drivers/scsi/scsi_mod.ko"
rm_files "${MODULES_DIR}/kernel/drivers/scsi/sd_mod.ko"
rm_files "${MODULES_DIR}/kernel/drivers/scsi/sg.ko"
