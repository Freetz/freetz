# We don't have getcons anymore but setconsole does the same
echo1 "removing /bin/getcons"
rm -f "${FILESYSTEM_MOD_DIR}/bin/getcons"
sed -i -e 's/getcons/setconsole/g' ${FILESYSTEM_MOD_DIR}/etc/profile