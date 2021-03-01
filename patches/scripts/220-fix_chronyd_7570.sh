[ "$FREETZ_TYPE_7570" == "y" ] || return 0
[ "$FREETZ_AVM_HAS_CHRONYD" == "y" ] || return 0
[ "$FREETZ_REMOVE_CHRONYD" == "y" ] && return 0
echo1 "fixing rtc device"

modsed "s#/var/dev/rtc#/dev/rtc#g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.rtc.sh"

