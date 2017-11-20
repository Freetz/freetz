
if [ "$FREETZ_REMOVE_MICROVOIP_DSL" == "y" ]; then
	echo1 "removing microvoip-dsl.bin file"
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip-dsl.bin" \
	  "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-*/kernel/drivers/atm/avm_atm/tiatm.ko" \
	  "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-*/kernel/drivers/char/ubik2/ubik2.ko"
fi

if [ "$FREETZ_ADD_ANNEX_A_FIRMWARE" == "y" ]; then
	echo1 "adding Annex A firmware file"
	cp "${DIR}/.tk/original/filesystem/lib/modules/dsp_ur8/ur8-A-dsl.bin" "${FILESYSTEM_MOD_DIR}/lib/modules/dsp_ur8"
fi

if [ "$FREETZ_REMOVE_ANNEX_B_FIRMWARE" == "y" ]; then
	echo1 "removing Annex B firmware file"
	rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/dsp_*/*-B-dsl.bin"
fi

if [ "$FREETZ_REMOVE_MULTI_ANNEX_FIRMWARE_DIFFS" == "y" ]; then
	echo1 "removing Multi-Annex firmware diff files"
	for files in \
	  lib/modules/dsp_*/*-?-dsl.bin.bsdiff \
	  lib/modules/dsp_*/*-?-dsl.bin.md5sum \
	  lib/modules/*Vx180Code.bin.bsdiff \
	  lib/modules/*Vx180Code.bin.md5sum \
	  usr/bin/bspatch \
	  ; do
		rm_files "${FILESYSTEM_MOD_DIR}/$files"
	done
	if [ "$FREETZ_REMOVE_MULTI_ANNEX_FIRMWARE_PRIME" == "y" ]; then
		echo1 "removing Multi-Annex firmware prime file"
		for files in \
		  lib/modules/dsp_*/*-?-dsl.bin \
		  lib/modules/*Vx180Code.bin.gz \
		  ${MODULES_SUBDIR}/kernel/drivers/vdsldriver/ \
		  usr/sbin/dsl_monitor \
		  etc/init.d/E40-dsl \
		  ; do
			rm_files "${FILESYSTEM_MOD_DIR}/$files"
		done
	fi
fi
