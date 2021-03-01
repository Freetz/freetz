
echo1 "preparing multid wrapper"

modsed \
  "s#\(^PATH=\)\(.*\)#\1/usr/bin/wrapper:\2#g" \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net" \
  "^PATH=/usr/bin/wrapper:"

