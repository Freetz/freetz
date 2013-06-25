[ "$FREETZ_REMOVE_ETHERNET_OVER_USB" == "y" ] || return 0
echo1 "removing avalanche_usb.ko"

rm_files "${MODULES_DIR}/kernel/drivers/net/avm_usb/avalanche_usb.ko"

# patcht Uebersicht > Anschluesse
sedfile="${HTML_SPEC_MOD_DIR}/home/home.html"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	modsed '/.*<tr>$/{N;N;N;/^[ \t]*<tr>\n.*StateLed("<? query usb:status.carrier ?>").*/d}' $sedfile
fi
