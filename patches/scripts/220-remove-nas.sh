[ "$FREETZ_REMOVE_NAS" == "y" ] || return 0

# if nas, mediaserv und samba are removed -> remove_nas deletes menu item Heimnetz > Speicher (NAS)
[ "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" -o "$FREETZ_REMOVE_SAMBA" == "y" ] &&
  [ "$FREETZ_REMOVE_MEDIASRV" == "y" ] && menulua_remove "storage\/settings"

echo1 "removing nas"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www.nas"
ln -sf www "${FILESYSTEM_MOD_DIR}/usr/www.nas"
rm_files \
  "${FILESYSTEM_MOD_DIR}/sbin/fritznasdb" \
  "${FILESYSTEM_MOD_DIR}/bin/showfritznasdbstat"
# REMOVE_MEDIASRV uses/removes libavmdb*.so
echo2 "removing internal memory"
rm -rf \
  ${FILESYSTEM_MOD_DIR}/etc/internal_memory_default_??/ \
  ${FILESYSTEM_MOD_DIR}/etc/internal_memory_default_??_*/ \
  ${FILESYSTEM_MOD_DIR}/etc/internal_memory_default*.tar

# patcht MyFRITZ! Menu
if [ "$FREETZ_REMOVE_MYFRITZ" != "y" ]; then
	modsed '/FRITZ!NAS/d' "${FILESYSTEM_MOD_DIR}/usr/www.myfritz/all/index.lua"
fi

# patcht Uebersicht
modsed '/.*uiViewTabSpeicherNas.*/{N;N;N;/537:880/d}' "${HTML_LANG_MOD_DIR}/home/home.lua"

# patcht Heimnetz > Speicher (NAS)
sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
if [ -e "$sedfile" ]; then
	echo1 "patching ${sedfile##*/}"
	sedrows=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<h4>{?80:518?}<.h4>.*$/\1/p')
	sedrowe=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<div id="page_bottom">.*$/\1/p')
	modsed "$((sedrows-1)),$((sedrowe-1))d" $sedfile
	modsed 's!<div id="btn_form_foot">!<div>\n&!' "$sedfile"
	modsed 's/\(jxl.disableNode("page_bottom",\).*/\1 false);/g' "$sedfile"

	# Fehler von AVM? http://freetz.org/ticket/2011
	modsed '/^if config.NAS then$/{N;s/^.*\(\nrequire("call_webusb")\)/if true then\1/g}' "$sedfile"
fi

# entfernt Links zu Fritz.NAS
quickstart_remove nas
modsed '/.*class="sm_link_bold" href=".nas.*/d' "${HTML_SPEC_MOD_DIR}/menus/menu2.html"

modsed "s/CONFIG_NAS.*/CONFIG_NAS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

