rm_files()
{
	for file in $1; do
		echo2 "$file"
		rm -rf "$file"
	done
}

if [ "$FREETZ_REMOVE_ANNEX_A_FIRMWARE" == "y" ]; then
	echo1 "removing Annex A firmware file"
	rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/dsp_ur8/ur8-A-dsl.bin"
fi

if [ "$FREETZ_REMOVE_ANNEX_B_FIRMWARE" == "y" ]; then
	echo1 "removing Annex B firmware file"
	rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/dsp_ur8/ur8-B-dsl.bin"
fi

