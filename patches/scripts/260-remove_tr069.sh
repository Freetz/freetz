if [ "$FREETZ_REMOVE_TR069" == "y" -o "$FREETZ_REMOVE_ASSISTANT" == "y" ]; then
	modsed \
	  's/\(^var doTr069 = \).*/\1false;/g' \
	  "${HTML_LANG_MOD_DIR}/html/logincheck.html"
	modsed \
	  's!http.redirect("/tr69_autoconfig/.*!go_home()!g' \
	  "${HTML_LANG_MOD_DIR}/lua/first.lua"
fi

[ "$FREETZ_REMOVE_TR069" == "y" ] || return 0

echo1 "removing tr069 stuff"
rm_files \
  "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr064.so" \
  "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr069.so" \
  "${FILESYSTEM_MOD_DIR}/sbin/tr069discover" \
  "${HTML_LANG_MOD_DIR}/tr69_autoconfig/"

[ "$FREETZ_REMOVE_TR069_FWUPDATE" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/tr069fwupdate"
[ "$FREETZ_REMOVE_TR069_HTTPSDL" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/httpsdl"

echo1 "patching default tr069.cfg"
find ${FILESYSTEM_MOD_DIR}/etc -name tr069.cfg -exec sed -e 's/enabled = yes/enabled = no/' -i '{}' \;

if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init" ]; then
	echo1 "patching /etc/init.d/rc.init"
	modsed "s/TR069=y/TR069=n/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init" "TR069=n$"
else
	echo1 "patching /etc/init.d/rc.conf"
	modsed "s/CONFIG_TR069=.*$/CONFIG_TR069=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" "CONFIG_TR069=\"n\"$"
	modsed "s/CONFIG_TR064=.*$/CONFIG_TR064=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" "CONFIG_TR064=\"n\"$"
fi

# delete tr069 config
echo "echo -n > /var/flash/tr069.cfg" > "${FILESYSTEM_MOD_DIR}/bin/tr069starter"

# remove providers-*.tar
[ "$FREETZ_REMOVE_TR069_PROVIDERS" == "y" ] || return 0
rm_files "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_*/*/providers-*.tar"

