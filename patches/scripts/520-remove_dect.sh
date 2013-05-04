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
modsed "s/document.write(Dect.\{1,10\}(.*))//g" "${HTML_SPEC_MOD_DIR}/home/home.html"
modsed "/jslGoTo('dect'/d;/^<?.*[dD]ect.*?>$/d" "${HTML_SPEC_MOD_DIR}/menus/menu2_konfig.html"
menu2html_remove dect

# don't patch this in firmwares < 05.5x (see http://freetz.org/ticket/2056)
if [ "$FREETZ_AVM_VERSION_05_5X_MIN" == "y" ]; then
	MODPROBEPIGLET=$(grep -l -i dect_firstlevelfile "${FILESYSTEM_MOD_DIR}/etc/init.d/"* 2>/dev/null)
	if [ -e "$MODPROBEPIGLET" ]; then
		echo1 "patching ${MODPROBEPIGLET##*/}"
		modsed '/^dect_[a-z]*levelfile=/ d; s!dect_[a-z]*levelfile=[^ ]*\.hex!!g' $MODPROBEPIGLET
	fi
fi

MODPROBEDECT=$(grep -l -i -e "^modprobe dect_io$" "${FILESYSTEM_MOD_DIR}/etc/init.d/"* 2>/dev/null)
if [ -e "$MODPROBEDECT" ]; then
	echo1 "patching ${MODPROBEDECT##*/}"
	modsed '/^modprobe dect_io$/d' $MODPROBEDECT
fi

echo1 "patching rc.conf"
modsed "s/\(CONFIG_.*DECT.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
