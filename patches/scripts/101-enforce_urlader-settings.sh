define_urlader_funcs() {
cat <<- 'EOF'
	# urlader functions
	get_urlader_var() {
	  sed -n -e "s/^$1[ \t]\+\(.*\)\$/\1/p" /proc/sys/urlader/environment
	}
	set_urlader_var() {
	  [ "$(get_urlader_var $1)" != "$2" ] && echo "$1 $2" >/proc/sys/urlader/environment
	}
EOF
}

set_desired_urlader_vars() {
local urlader_var freetz_config_var
for urlader_var in firmware_version my_ipaddress ProductID; do
	freetz_config_var="FREETZ_ENFORCE_URLADER_SETTING_${urlader_var^^}"
	if [ -n "${!freetz_config_var}" ]; then
		cat <<- EOF
		set_urlader_var "${urlader_var}" "${!freetz_config_var}"
		EOF
	fi
done
}

mount_proc() {
cat <<- 'EOF'
	mount -t proc proc /proc
EOF
}

umount_proc() {
cat <<- 'EOF'
	umount /proc
EOF
}

[ "$FREETZ_ENFORCE_URLADER_SETTINGS" = y -a -n "$(set_desired_urlader_vars)" ] || return 0

echo1 "enforce urlader settings"

{
	rc_S="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

	{
		echo
		echo "# override urlader variables"
		echo "$(set_desired_urlader_vars)"
		echo
	} > "${rc_S}.urlader_vars"

	{
		# copy the 1st line (according to the standard must be a shebang line)
		sed -n -e '1p' "${rc_S}"

		# add the definitions of the urlader getter/setter funcs
		echo
		echo "$(define_urlader_funcs)"
		echo

		# add mount/umount lines if rc.S doesn't contain
		# the "mount -t proc ..." line yet
		if ! grep -q "^$(mount_proc)$" "${rc_S}" >/dev/null 2>&1; then
			echo "$(mount_proc)"
			echo "$(umount_proc)"
		fi

		# copy all lines starting from the 2nd one, i.e. except for the 1st one
		sed -e '1d' "${rc_S}"
	} | {
		# append "set_urlader_var"-calls after the "mount -t proc ..." line
		sed -e '\#'^"$(mount_proc)"'$# r '"${rc_S}.urlader_vars"
	} > "${rc_S}.modified"

	rm -f "${rc_S}.urlader_vars"
}

chmod 755 "${rc_S}.modified"
mv "${rc_S}.modified" "${rc_S}"
