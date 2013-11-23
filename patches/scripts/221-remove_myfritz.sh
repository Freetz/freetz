[ "$FREETZ_REMOVE_MYFRITZ" = "y" ] || return 0

echo1 "removing myfritz"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www.myfritz"
ln -s www "${FILESYSTEM_MOD_DIR}/usr/www.myfritz"

rm_files "${HTML_LANG_MOD_DIR}/internet/myfritz*.lua"

#lua
homelua_disable tr_myfritz
quickstart_remove myfritz
linkbox_remove myfritz
#html
if [ "$FREETZ_AVM_HAS_ONLY_LUA" != "y" ]; then
	linkbox_file="${HTML_SPEC_MOD_DIR}/menus/menu2.html"
	linkbox_row=$(cat $linkbox_file |nl| sed -n "s/^ *\([0-9]*\).*<a href=..myfritz.. target=._blank.>.*<.a>$/\1/p")
	modsed "$((linkbox_row-8)),$((linkbox_row+18))d" $linkbox_file
	modsed '/.*class="sm_link_bold" href=".myfritz.*/d' "${HTML_SPEC_MOD_DIR}/menus/menu2.html"
	modsed 's/\(setvariable var:showmyfritz \)./\10/g' ${HTML_SPEC_MOD_DIR}/menus/menu2_internet.html
fi

modsed "s/CONFIG_MYFRITZ=.*/CONFIG_MYFRITZ=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
