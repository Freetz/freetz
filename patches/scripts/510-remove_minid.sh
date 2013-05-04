[ "$FREETZ_REMOVE_MINID" == "y" ] || return 0
echo1 "removing minid files"
for files in \
  bin/minid \
  bin/minidcfg \
  bin/cjpeg \
  bin/djpeg \
  bin/email.plugin \
  bin/ffmpegconv \
  bin/music.plugin \
  bin/playerd \
  bin/playerd_tables \
  bin/pnm* \
  bin/rdjpgcom \
  bin/rssagg.plugin \
  bin/streamer.plugin \
  bin/telephon.plugin \
  bin/update.plugin \
  etc/minid \
  lib/libflashclient.so* \
  lib/libmediacli.so* \
  lib/libnetpbm.so* \
  usr/share/ctlmgr/libmini.so \
  etc/default.*/*/ringtone.wav \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
# REMOVE_MEDIASRV uses/removes libavmid3*.so

[ "$FREETZ_REMOVE_VOIPD" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libfoncclient*"
[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmid3*.so*"
[ "$FREETZ_REMOVE_AURA_USB" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavm_audio.so*"
[ "$FREETZ_HAS_AVM_DECT" != "y" -o "$FREETZ_REMOVE_DECT" == "y" ] && \
for files in \
  lib/libavcodec.so* \
  lib/libavformat.so* \
  lib/libavutil.so* \
  lib/libhttp.so* \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

# purge contents of rc.media
[ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.media" ] && echo > "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.media"

echo1 "patching rc.conf"
modsed "s/CONFIG_MINI=.*$/CONFIG_MINI=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
