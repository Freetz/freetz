[ "$FREETZ_REMOVE_MINID" == "y" ] || return 0
echo1 "removing minid files"
for files in \
	bin/minid \
	bin/minidcfg \
	bin/email.plugin \
	bin/music.plugin \
	bin/rssagg.plugin \
	bin/streamer.plugin \
	bin/telephon.plugin \
	bin/update.plugin \
	etc/minid \
	usr/share/ctlmgr/libmini.so \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

