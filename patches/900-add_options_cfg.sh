OPTIONS_CFG="${FILESYSTEM_MOD_DIR}/etc/options.cfg"

check_options() {
	[ "$1" != "y" ] && return
	shift
	for current_option in $*; do
		current_value="$(eval echo \$$current_option)"
		if [ "$current_value" != "n" -a "$current_value" != "" ]; then
			echo2 "adding $current_option"
			echo "$current_option='$current_value'" >> $OPTIONS_CFG
		fi
	done
}

echo1 "creating options.cfg"

if [ "$FREETZ_REMOVE_DOT_CONFIG" != "y" ]; then

echo2 "by symlinking it to .config"
ln -snf .config $OPTIONS_CFG

else

check_options "$FREETZ_PACKAGE_DAVFS2" \
	FREETZ_PACKAGE_DAVFS2_WITH_SSL
check_options "$FREETZ_PACKAGE_LIGHTTPD" \
	FREETZ_PACKAGE_LIGHTTPD_WITH_SSL \
	FREETZ_PACKAGE_LIGHTTPD_MOD_ACCESSLOG \
	FREETZ_PACKAGE_LIGHTTPD_MOD_AUTH \
	FREETZ_PACKAGE_LIGHTTPD_MOD_EVHOST \
	FREETZ_PACKAGE_LIGHTTPD_MOD_DIRLISTING \
	FREETZ_PACKAGE_LIGHTTPD_MOD_REDIRECT \
	FREETZ_PACKAGE_LIGHTTPD_MOD_CGI \
	FREETZ_PACKAGE_LIGHTTPD_MOD_COMPRESS \
	FREETZ_PACKAGE_LIGHTTPD_MOD_STATUS \
	FREETZ_PACKAGE_LIGHTTPD_MOD_FASTCGI
check_options "$FREETZ_PACKAGE_NANO" \
	FREETZ_PACKAGE_NANO_NANORC \
	FREETZ_PACKAGE_NANO_TINY \
	FREETZ_PACKAGE_NANO_COLOR_SYNTAX
check_options "$FREETZ_PACKAGE_OPENDD" \
	FREETZ_PACKAGE_OPENDD_WITH_SSL
check_options "$FREETZ_PACKAGE_VSFTPD" \
	FREETZ_PACKAGE_VSFTPD_WITH_SSL

fi
