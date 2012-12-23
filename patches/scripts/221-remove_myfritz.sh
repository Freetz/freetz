[ "$FREETZ_REMOVE_MYFRITZ" = "y" ] || return 0

echo1 "removing myfritz"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www.myfritz"
ln -s www "${FILESYSTEM_MOD_DIR}/usr/www.myfritz"

homelua_disable tr_myfritz
quickstart_remove myfritz

#Link in Box unter dem Menü links
sedfile="${FILESYSTEM_MOD_DIR}/usr/www/all/templates/menu_page_head.html"
echo1 "patching ${sedfile##*/}"
myfritz_row=$(cat $sedfile |nl| sed -n "s/^ *\([0-9]*\).*menu.write_menu('myfritz')$/\1/p")
modsed "$((myfritz_row-6)),$((myfritz_row+9))d" $sedfile

modsed "s/CONFIG_MYFRITZ=.*/CONFIG_MYFRITZ=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
