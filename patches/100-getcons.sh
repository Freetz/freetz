# Setconsole does the same. So delete getcons.
echo1 "removing /bin/getcons"
rm -f "${FILESYSTEM_MOD_DIR}/bin/getcons"
sed -i -e 's/getcons/setconsole/g' ${FILESYSTEM_MOD_DIR}/etc/profile

if [ "$DS_PATCH_GETCONS" == "y" ]; then
	sed -i -e '/setconsole/d' ${FILESYSTEM_MOD_DIR}/etc/profile
	sed -i -e '/Console Ausgaben/d' ${FILESYSTEM_MOD_DIR}/etc/profile
fi
