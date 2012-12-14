[ "$FREETZ_REMOVE_DSLD" == "y" ] || return 0

echo1 "removing dsld files"
rm_files \
	"${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libdsl.so" \
	 $(find ${FILESYSTEM_MOD_DIR}/sbin \
				${FILESYSTEM_MOD_DIR}/lib/modules \
				-name dsld)

if [ -e "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init" ]; then
	modsed "s/DSL=y/DSL=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
else
	modsed "s/CONFIG_DSL=y/CONFIG_DSL=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
fi

