[ "$FREETZ_TYPE_EXTENDER" == "y"  ] || return 0
[ "$FREETZ_TYPE_1759" == "y" ] || return 0
[ "$FREETZ_AVM_VERSION_06_2X_MAX" == "y" ] || return 0
echo1 "enabling dvb-c tv-services"

# patcht DVB-C > TV-Dienste
modpatch \
  "$FILESYSTEM_MOD_DIR" \
  "${PATCHES_COND_DIR}/822-show_dvb_services.patch"

