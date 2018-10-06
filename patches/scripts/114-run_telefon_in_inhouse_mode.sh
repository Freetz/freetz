[ "${FREETZ_RUN_TELEFON_IN_INHOUSE_MODE}" == "y" ] || return 0

# CONFIG_RELEASE=0: in-house development version
# CONFIG_RELEASE=1: official release
# CONFIG_RELEASE=2: public beta/labor version

echo1 "forcing telefon daemon to run in in-house mode"
modsed -r 's,^([ \t]*)(telefon[ \t]),\1CONFIG_RELEASE=0 \2,' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.voip" '^[ \t]*CONFIG_RELEASE=0 telefon[ \t]'
