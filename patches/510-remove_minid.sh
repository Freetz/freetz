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
#	$(find ${FILESYSTEM_MOD_DIR} -iwholename "*usr/www/*/html/*mini*" ! -iname "*mini*.gif" ! -iname "*Mini.js" -printf "%P\n") \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

echo1 "patching rc.conf"
sed -i -e "s/CONFIG_MINI=.*$/CONFIG_MINI=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
