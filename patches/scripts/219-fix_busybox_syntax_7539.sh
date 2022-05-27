[ "$FREETZ_TYPE_7539" == "y" ] || return 0
[ "$FREETZ_AVM_VERSION_07_25_MAX" == "y" ] || return 0
echo1 "fixing busybox syntax"

modsed 's/if \[ ${#wlx\[@\]} == 0 \]; then/if [ -z "$wlx" ]; then/' "${FILESYSTEM_MOD_DIR}/etc/init.d/bcm-wlan-drivers.sh"

