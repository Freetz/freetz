[ "$FREETZ_REMOVE_DECT" == "y" ] || return 0
[ "$FREETZ_AVM_HAS_DECT" != "y" -a "$FREETZ_AVM_VERSION_06_2X_MIN" == "y" ] || return 0
echo1 "removing DECT related files on non-DECT box"

for f in \
  "${MODULES_DIR}/kernel/drivers/net/nlaudio/nlaudio.ko" \
  "${MODULES_DIR}/kernel/drivers/net/nlaudio/ulpcmlink.ko" \
  ; do
	[ -e "$f" ] && rm_files "$f"
done

