[ "$FREETZ_REMOVE_TR069" == "y" ] || return 0
echo1 "removing tr069"

rm_files \
  "${FILESYSTEM_MOD_DIR}/sbin/tr069discover" \
  "${HTML_LANG_MOD_DIR}/tr69_autoconfig/"

[ "$FREETZ_REMOVE_TR069_FWUPDATE" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/tr069fwupdate"
[ "$FREETZ_REMOVE_TR069_HTTPSDL" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/httpsdl"
if [ "$FREETZ_REMOVE_TR069_PROVIDERS" == "y" ]; then
	rm_files "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_*/*/providers-*.tar"
	[ -e "${HTML_LANG_MOD_DIR}/lua/isp.lua" ] && sedfile="${HTML_LANG_MOD_DIR}/lua/isp.lua" || sedfile="${FILESYSTEM_MOD_DIR}/usr/lua/isp.lua"
	modsed \
	  's!\(list\[other.id\].providername=other.name\)!if other.id~=nil then\n\1\nend!' \
	  "$sedfile"
fi
[ "$FREETZ_REMOVE_TR069_VOIPPROVIDERS" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_*/*/voip_providers-*.tar"

# verhindert Nagscreen nach dem ersten Login mit Erlaubnis fuer Diagnosedaten und Portforward
modsed \
  's!.*local diagInconsistent *=!&false --OLD VALUE: !' \
  "${LUA_MOD_DIR}/first.lua"


echo1 "patching default tr069.cfg"
find ${FILESYSTEM_MOD_DIR}/etc -name tr069.cfg -exec sed -e 's/enabled = yes/enabled = no/' -i '{}' \;

if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init" ]; then
	echo1 "patching /etc/init.d/rc.init"
	modsed "s/TR069=y/TR069=n/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init" "TR069=n$"
else
	echo1 "patching /etc/init.d/rc.conf"
	modsed "s/CONFIG_TR069=.*$/CONFIG_TR069=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" "CONFIG_TR069=\"n\"$"
fi

# delete tr069 config
echo "echo -n > /var/flash/tr069.cfg" > "${FILESYSTEM_MOD_DIR}/bin/tr069starter"

