[ "$FREETZ_LIB_libctlmgr" == "y" ] || return 0

create_LD_PRELOAD_wrapper /usr/bin/ctlmgr libctlmgr.so
