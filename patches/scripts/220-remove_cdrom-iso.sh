[ "$FREETZ_REMOVE_CDROM_ISO" == "y" ] || return 0

echo1 "removing cdrom.iso"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/cdrom.iso"

# remove unnecessary lines
modsed -r '/[ \t]*(tmp_iso_path=|## Fallback: Wenn nach 200 Sekunden das CDROM nicht aktiviert wird|echo "usb client: CDROM Fallback).*/ d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

# replace 'modprobe avalanche_usb use_cdrom=...' with 'modprobe avalanche_usb use_cdrom=0'
modsed -r 's,^([ \t]*modprobe avalanche_usb use_cdrom)=.*$,\1=0,' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
