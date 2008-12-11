if [ "$FREETZ_ADD_ANNEX_A_FIRMWARE" == "y" ]; then
	echo1 "adding Annex A firmware file"
	cp "${DIR}/.tk/original/filesystem/lib/modules/dsp_ur8/ur8-A-dsl.bin" "${FILESYSTEM_MOD_DIR}/lib/modules/dsp_ur8"
fi

if [ "$FREETZ_REMOVE_ANNEX_B_FIRMWARE" == "y" ]; then
	echo1 "removing Annex B firmware file"
	rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/dsp_ur8/ur8-B-dsl.bin"
fi

