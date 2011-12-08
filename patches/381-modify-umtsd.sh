[ "$FREETZ_MODIFY_UMTSD" == "y" ] || return 0
echo1 "modifying umtsd files"

#mark if device is unknown
modsed 's/\(echo "Modem $VID:$PID not listed!"\)/UMTSDEV=0 ;\1/;s/*) ;;/*) UMTSDEV=0 ;;/g' \
  "${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-gsm-tty" 'UMTSDEV=0'

#onyl start if device is known
modsed 's/^umtsd$/[ "$UMTSDEV" != "0" ] \&\& &/g' \
  "${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-gsm-tty" '"$UMTSDEV"'

