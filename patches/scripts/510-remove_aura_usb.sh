[ "$FREETZ_REMOVE_AURA_USB" == "y" ] || return 0
echo1 "removing aura-usb files"
for files in \
  ${HTML_SPEC_MOD_DIR}/usb/pp_aura.html \
  ${HTML_SPEC_MOD_DIR}/usb/aura.* \
  ${HTML_SPEC_MOD_DIR}/usb/auraactiv.* \
  ${HTML_SPEC_MOD_DIR}/usb/aurachange.* \
  ${FILESYSTEM_MOD_DIR}/bin/aurad \
  ${FILESYSTEM_MOD_DIR}/bin/auracntl \
  ${FILESYSTEM_MOD_DIR}/bin/aurachanged \
  ${FILESYSTEM_MOD_DIR}/etc/hotplug/aura \
  ; do
	rm_files "$files"
done

# patcht USB-Geraete > Geraeteuebersicht > USB-Fernanschluss aktivieren
sedfile="${HTML_SPEC_MOD_DIR}/usb/status.html"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	sedrow=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*"uiAuraEnable".*$/\1/p')
	modsed "$((sedrow-2)),$((sedrow+3))d" $sedfile
	modsed "/.*btnSave.*/d" $sedfile
fi

echo1 "patching rc.conf"
modsed "s/CONFIG_AURA=.*$/CONFIG_AURA=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

