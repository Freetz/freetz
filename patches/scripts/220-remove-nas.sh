[ "$FREETZ_REMOVE_NAS" == "y" ] || return 0

echo1 "removing nas"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www.nas"
ln -sf www "${FILESYSTEM_MOD_DIR}/usr/www.nas"
rm_files \
  "${FILESYSTEM_MOD_DIR}/sbin/fritznasdb" \
  "${FILESYSTEM_MOD_DIR}/bin/showfritznasdbstat"
# REMOVE_MEDIASRV uses/removes libavmdb*.so

# patcht Heimnetz > Speicher (NAS). Fehler von AVM? http://freetz.org/ticket/2011
modsed '/^if config.NAS then$/{N;s/^.*\(\nrequire("call_webusb")\)/if true then\1/g}' "${HTML_LANG_MOD_DIR}/storage/settings.lua"

# entfernt Links zu Fritz.NAS
quickstart_remove nas
modsed '/.*class="sm_link_bold" href=".nas.*/d' "${HTML_SPEC_MOD_DIR}/menus/menu2.html"

echo2 "removing internal memory"
rm -rf ${FILESYSTEM_MOD_DIR}/etc/internal_memory_default*.tar

modsed "s/CONFIG_NAS.*/CONFIG_NAS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
