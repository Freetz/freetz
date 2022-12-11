
echo1 "preparing multid wrapper"

wrapath="/usr/bin/wrapper/"
for daemon in dsld multid rextd; do
	file="${FILESYSTEM_MOD_DIR}/lib/systemd/system/$daemon.service"
	[ -e "$file" ] || continue
	modsed -r \
	  "s,^(ExecStart *=).*/*($daemon *.*)$,\1$wrapath\2," \
	  "$file" \
	  "$wrapath$daemon"
done

grep -q "^PATH=" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net" || sed '2 i\PATH=$PATH' -i "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"

modsed \
  "s#\(^PATH=\)\(.*\)#\1/usr/bin/wrapper:\2#g" \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net" \
  "^PATH=/usr/bin/wrapper:"

