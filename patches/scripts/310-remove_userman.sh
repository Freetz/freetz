[ "$FREETZ_REMOVE_USERMAN" == "y" ] || return 0
echo1 "removing userman files"
rm_files \
  ${FILESYSTEM_MOD_DIR}/bin/userman* \
  ${HTML_LANG_MOD_DIR}/internet/kids*.lua \
  $(find ${HTML_LANG_MOD_DIR} -name 'userlist*' -o -name 'useradd*')

# Prevent continous reboots on 3170 with replace kernel
if [ "$FREETZ_REMOVE_DSLD" = "y" ] || ! ( isFreetzType 3170 && [ "$FREETZ_REPLACE_KERNEL" = "y" ] ); then
	rm_files $(find ${FILESYSTEM_MOD_DIR}/lib/modules -name userman)
else
	modsed "s/^modprobe kdsldmod$/modprobe kdsldmod\nmodprobe userman/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

# patcht Heimnetz > Netzwerk > Bearbeiten > Kindersicherung
modsed '/<.lua show_kisi_content() .>/d' "${HTML_LANG_MOD_DIR}/net/edit_device.lua"

# redirect on webif to prio settings
for j in home.html menu2_internet.html; do
	for i in $(find "${HTML_LANG_MOD_DIR}" -type f -name $j); do
		modsed "s/'userlist'/'trafficprio'/g" $i
	done
done

for j in userlist useradd; do
	for i in $(find "${HTML_LANG_MOD_DIR}" -type f -name '*.html' | xargs grep -l $j); do
		modsed "/$j/d" $i
	done
done

if [ -e "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init" ]; then
	modsed "s/KIDS=y/KIDS=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
else
	modsed "s/CONFIG_KIDS=.*$/CONFIG_KIDS=\"n\"/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
fi

