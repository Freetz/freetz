[ "$FREETZ_SYSTEM_TYPE_IKS" == "y" ] || return 0
echo1 "fix 7390 reboot problem on dect module unload"

modsed '/rmmod .*dect/d' "$VARTAR_MOD_DIR/var/post_install"

