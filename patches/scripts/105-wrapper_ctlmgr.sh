[ "$FREETZ_LIB_libctlmgr" == "y" ] || return 0
echo1 "preparing ctlmgr wrapper"

create_LD_PRELOAD_wrapper /usr/bin/ctlmgr libctlmgr.so

