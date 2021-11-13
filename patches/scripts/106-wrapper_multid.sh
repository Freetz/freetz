
echo1 "preparing multid wrapper"

grep -q "^PATH=" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net" || sed '2 i\PATH=$PATH' -i "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"

modsed \
  "s#\(^PATH=\)\(.*\)#\1/usr/bin/wrapper:\2#g" \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net" \
  "^PATH=/usr/bin/wrapper:"

