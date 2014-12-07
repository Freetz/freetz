[ "$FREETZ_AVM_HAS_DECT" == "y" -o "$FREETZ_AVM_VERSION_06_0X_MAX" == "y" ] && return 0

for f in \
	"${MODULES_DIR}/kernel/drivers/net/nlaudio/nlaudio.ko" \
	"${MODULES_DIR}/kernel/drivers/net/nlaudio/ulpcmlink.ko" \
; do
	[ ! -e "$f" ] && continue

	echo1 "removing DECT related file on non-DECT box: ${f/${FILESYSTEM_MOD_DIR}}"
	rm_files "$f"
done
