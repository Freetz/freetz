# Setconsole does the same. So delete getcons.
echo1 "removing /bin/getcons"
rm_files "${FILESYSTEM_MOD_DIR}/bin/getcons"
sed -i -e 's/getcons/setconsole/g' ${FILESYSTEM_MOD_DIR}/etc/profile

if [ "$FREETZ_PATCH_GETCONS" == "y" ]; then
	sed -i -e '/setconsole/d' ${FILESYSTEM_MOD_DIR}/etc/profile
	sed -i -e 's/auf dieses Terminal/nicht/' ${FILESYSTEM_MOD_DIR}/etc/profile
fi
