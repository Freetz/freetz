var_install_file="${FIRMWARE_MOD_DIR}/var/install"

if grep -q "find [.] -name dd" "${var_install_file}" 2>/dev/null; then
	echo1 "fixing test for dd in /var/install"
	modsed -r 's,(find )[.]( -name dd)( -xdev),\1/bin/\3 -maxdepth 1\2,g' "${var_install_file}"
fi

if grep -q "bs=256 skip=1 conv=sync" "${var_install_file}" 2>/dev/null; then
	echo1 "removing unnecessary conv=sync option from dd call in /var/install"
	modsed -r 's,(bs=256 skip=1) conv=sync,\1,' "${var_install_file}"
fi
