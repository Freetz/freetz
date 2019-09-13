[ "$FREETZ_FWMOD_BUGGY_FLASH_COMPAT" = "y" ] || return 0

echo1 "compatibility for forks with buggy flash"

grep "find [.] -name dd" "${var_install_file}" &>/dev/null && modsed -r 's,(find )[.]( -name dd)( -xdev),\1/bin/\3 -maxdepth 1\2,g' "${var_install_file}"

