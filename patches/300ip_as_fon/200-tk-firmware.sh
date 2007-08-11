if [ -z "$FIRMWARE2" ]
then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

# remove other oems
[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}removing oem: 1und1 aol arcor freenet"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www/1und1"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www/aol"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www/arcor"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www/freenet"
rm -rf "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_FON/1und1"
rm -rf "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_FON/aol"
rm -rf "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_FON/arcor"
rm -rf "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_FON/freenet"
rm -f "${FILESYSTEM_MOD_DIR}/etc/default.049/fx_lcr.1und1"
rm -f "${FILESYSTEM_MOD_DIR}/etc/default.049/fx_lcr.aol"
rm -f "${FILESYSTEM_MOD_DIR}/etc/default.049/fx_lcr.arcor"
rm -f "${FILESYSTEM_MOD_DIR}/etc/default.049/fx_lcr.freenet"
rm -f "${FILESYSTEM_MOD_DIR}/etc/default.049/fx_lcr.tcom"
cp -p "${FILESYSTEM_MOD_DIR}/etc/default.049/fx_lcr.default" "${FILESYSTEM_MOD_DIR}/etc/default.049/fx_lcr.tcom"

# install script
[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}applying install patch"
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-300ip-as-fon.patch" || exit 2

# rc.init
[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}adding hw revision 78"
echo "#-----------------------------------------------------" >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
cat "${DIR}/.tk/original/filesystem/etc/init.d/rc.init" | grep "HW=78" >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"

# oem symlink
[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}creating symlinks for tcom"
ln -sf /usr/www/cgi-bin/dsmod_status "${FILESYSTEM_MOD_DIR}/usr/www/all/cgi-bin/dsmod_status"
ln -sf avm "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_FON/tcom"
ln -sf default.Fritz_Box_FON "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_Eumex300IP"
ln -sf illu.gif "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/images/tcom_illu.gif"
ln -sf Gruene_Leitung.gif "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/images/tcom_Gruene_Leitung.gif"
ln -sf Rote_Leitung.gif "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/images/tcom_Rote_Leitung.gif"

# copy led.conf
[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}copying led.conf"
cp -f "${DIR}/.tk/original/filesystem/etc/led.conf" "${FILESYSTEM_MOD_DIR}/etc/led.conf"
