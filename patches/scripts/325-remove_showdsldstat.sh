[ "$FREETZ_REMOVE_SHOWDSLDSTAT" == "y" ] || return 0

echo1 "removing showdsldstat file"
rm_files $(find ${FILESYSTEM_MOD_DIR}/sbin -name showdsldstat)

if [ "$FREETZ_AVM_HAS_WEBDAV" == "y" -a "$FREETZ_REMOVE_WEBDAV" != "y" ]; then
	modsed 's/ -o ! -x $EXE_SHOWDSLDSTAT//' "$FILESYSTEM_MOD_DIR/etc/webdav_control"
fi
