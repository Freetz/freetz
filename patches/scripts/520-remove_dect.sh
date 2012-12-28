[ "$FREETZ_REMOVE_DECT" == "y" ] || return 0
echo1 "removing DECT files"
for files in \
	bin/supportdata.dect \
	sbin/start_dect_update.sh \
	usr/bin/dect_manager \
	usr/share/ctlmgr/libdect.so \
	lib/modules/dectfw_firstlevel.hex \
	lib/modules/dectfw_secondlevel.hex \
	$(find ${FILESYSTEM_MOD_DIR} -iwholename "*usr/www/*/html/*dect*" -printf "%P\n") \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
rm_files $(find ${FILESYSTEM_MOD_DIR}/lib/modules -name "*dect*.ko")

[ "$FREETZ_REMOVE_MINID" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libfoncclient.so*"

echo1 "patching web UI"
modsed "s/document.write(Dect.\{1,10\}(.*))//g" "${HTML_LANG_MOD_DIR}/html/de/home/home.html"
modsed "/jslGoTo('dect'/d;/^<?.*[dD]ect.*?>$/d" "${HTML_LANG_MOD_DIR}/html/de/menus/menu2_konfig.html"
menu2html_remove dect

if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/S17-capi" ]; then
	sedfile="${FILESYSTEM_MOD_DIR}/etc/init.d/S17-capi"
	echo1 "patching ${sedfile##*/}"
elif [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/S17-isdn" ]; then
	sedfile="${FILESYSTEM_MOD_DIR}/etc/init.d/S17-isdn"
	echo1 "patching ${sedfile##*/}"
	modsed 's!dect_firstlevelfile=/lib/modules/dectfw_firstlevel_488.hex!!' $sedfile
	modsed 's!dect_secondlevelfile=/lib/modules/dectfw_secondlevel_488.hex!!' $sedfile
else
	sedfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	echo1 "patching ${sedfile##*/}"
	modsed '/dect.*firstlevel/d' $sedfile
	modsed '/dect.*secondlevel/d' $sedfile
fi
modsed "s/^modprobe dect_io$//g" $sedfile

echo1 "patching rc.conf"
modsed "s/\(CONFIG_.*DECT.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
