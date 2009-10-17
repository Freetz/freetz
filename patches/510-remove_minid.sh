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
	lib/libavcodec.so* \
	lib/libavformat.so* \
	lib/libavm_audio.so* \
	lib/libavutil.so* \
	lib/libflashclient.so* \
	lib/libhttp.so* \
	lib/libmediacli.so* \
	usr/share/ctlmgr/libmini.so \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

[ "$FREETZ_REMOVE_VOIPD" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libfoncclient*"
[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmid3*.so*"

echo1 "patching rc.conf"
modsed "s/CONFIG_MINI=.*$/CONFIG_MINI=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
