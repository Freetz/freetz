[ "$FREETZ_REMOVE_MYFRITZ" = "y" ] || return 0;

echo1 "removing myfritz"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www.myfritz"
ln -s www "${FILESYSTEM_MOD_DIR}/usr/www.myfritz"

modsed "s/CONFIG_MYFRITZ=.*/CONFIG_MYFRITZ=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
