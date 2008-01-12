[ "$DS_PACKAGE_IPTABLES" == "y" ] || return 0
echo1 "Copying iptables libs"
LIBPATH="${FILESYSTEM_MOD_DIR}/usr/lib/iptables"
mkdir -p $LIBPATH

for i in \
$( \
	cd "${KERNEL_REP_DIR}/root" && \
	find lib usr/lib -type d -name .svn -prune -false , -type f -name "*.so*" \
)
do
	bn="$(basename "$i")"
	lib="${bn%\.so*}"
	lib="$(echo "$lib" | sed -e 's/-[\.0-9]*$//')"
	if [ "$(eval "echo \"\$DS_LIB_$(echo "$lib" | tr '\-+' '_x')\"")" == "y" ]; then
		echo2 "${bn}"
		dn="$(dirname "$i")"
		[ -d "${FILESYSTEM_MOD_DIR}/${dn}" ] || mkdir -p "${FILESYSTEM_MOD_DIR}/${dn}"
		cp -a "${KERNEL_REP_DIR}/root/${dn}/${lib}"[-\|\.]*so* "${FILESYSTEM_MOD_DIR}/${dn}/"
		chmod +x "${FILESYSTEM_MOD_DIR}/${i}"
fi
done
