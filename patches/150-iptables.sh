[ "$FREETZ_PACKAGE_IPTABLES" == "y" ] || return 0
echo1 "Copying iptables"
IPTABLES_DIR=${PACKAGES_DIR}/iptables-1.4.1.1
IPTABLES_BINARY=$IPTABLES_DIR/root/usr/sbin/iptables
IP6TABLES_BINARY=$IPTABLES_DIR/root/usr/sbin/ip6tables
IPTABLES_DEST_BINARY="${FILESYSTEM_MOD_DIR}/usr/sbin"
EXT_DIR="$IPTABLES_DIR/usr/lib/xtables"
EXT_DEST_DIR="${FILESYSTEM_MOD_DIR}/usr/lib/xtables"
mkdir -p $EXT_DEST_DIR

cp $IPTABLES_BINARY $IPTABLES_DEST_BINARY
[ -e $IP6TABLES_BINARY ] && cp $IP6TABLES_BINARY $IPTABLES_DEST_BINARY

for i in \
$( \
	cd "$IPTABLES_DIR/root" && \
	find usr/lib -type d -name .svn -prune -false , -type f -name "*.so*" \
)
do
	bn="$(basename "$i")"
	lib="${bn%\.so*}"
	lib="$(echo "$lib" | sed -e 's/-[\.0-9]*$//')"
	if [ "$(eval "echo \"\$FREETZ_LIB_$(echo "$lib" | tr '\-+' '_x')\"")" == "y" ]; then
		echo2 "${bn}"
		dn="$(dirname "$i")"
		[ -d "${FILESYSTEM_MOD_DIR}/${dn}" ] || mkdir -p "${FILESYSTEM_MOD_DIR}/${dn}"
		cp -a "$IPTABLES_DIR/root/${dn}/${lib}"[-\|\.]*so* "${FILESYSTEM_MOD_DIR}/${dn}/"
		chmod +x "${FILESYSTEM_MOD_DIR}/${i}"
fi
done
