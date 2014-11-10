for f in \
	/bin/more \
	/usr/bin/ncurses5-config \
; do
	[ -e "${FILESYSTEM_MOD_DIR}${f}" ] || continue
	echo1 "removing ${f}"
	rm_files "${FILESYSTEM_MOD_DIR}${f}"
done
