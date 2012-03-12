
if [ "$FREETZ_ADD_ANNEX_A_FIRMWARE" == "y" ]; then
	echo1 "adding Annex A firmware file"
	cp "${DIR}/.tk/original/filesystem/lib/modules/dsp_ur8/ur8-A-dsl.bin" "${FILESYSTEM_MOD_DIR}/lib/modules/dsp_ur8"
fi

if [ "$FREETZ_REMOVE_ANNEX_A_FIRMWARE" == "y" ]; then
	echo1 "removing Annex A firmware file"
	rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/dsp_*/*-A-dsl.bin"
fi

if [ "$FREETZ_REMOVE_ANNEX_B_FIRMWARE" == "y" ]; then
	echo1 "removing Annex B firmware file"
	rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/dsp_*/*-B-dsl.bin"
fi

if [ "$FREETZ_REMOVE_MULTI_ANNEX_FIRMWARE" == "y" ]; then
	echo1 "removing Multi-Annex firmware files"
	for files in \
	 	lib/modules/dsp_*/*-?-dsl.bin* \
	 	lib/modules/*Vx180Code* \
	 	usr/bin/bspatch \
		; do
		rm_files "${FILESYSTEM_MOD_DIR}/$files"
	done
fi
