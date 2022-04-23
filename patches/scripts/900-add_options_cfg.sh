
echo1 "creating options.cfg"

OPTIONS_CFG="${FILESYSTEM_MOD_DIR}/etc/options.cfg"
if [ "$FREETZ_CREATE_SEPARATE_OPTIONS_CFG" != "y" ]; then
	echo2 "by symlinking it to .config"
	ln -snf .config $OPTIONS_CFG
else
	OPTIONS_FILES="$(find make/*/files/root/etc/init.d/rc.* make/*/files/root/etc/default.*/*_conf; \
	  find make/*/files/root/usr/ -type f \( -name '*.cgi' -o -name '*.sh' \))"
	OPTIONS_NAMES="$(grep -hoE "FREETZ_REPLACE_KERNEL|FREETZ_TYPE_[A-Z0-9_]*|FREETZ_AVMDAEMON_DISABLE_[A-Z0-9]*|FREETZ_AVM_HAS_[A-Z0-9_]*|FREETZ_AVM_VERSION_[X0-9_]*(_MIN)?|FREETZ_(TARGET|BUSYBOX)_[A-Z0-9_]*|EXTERNAL_DYNAMIC[a-zA-Z0-9_]*|(EXTERNAL_)?FREETZ_(PACKAGE|LIB|PATCH|ADD|CUSTOM|LANG)[a-zA-Z0-9_]*" $OPTIONS_FILES | sort -u)"
	for OPTIONS_CURRENT in $OPTIONS_NAMES; do
		OPTIONS_VALUE="$(eval echo \$$OPTIONS_CURRENT)"
		if [ "$OPTIONS_VALUE" != "n" -a "$OPTIONS_VALUE" != "" ]; then
			echo2 "adding $OPTIONS_CURRENT"
			echo "$OPTIONS_CURRENT='$OPTIONS_VALUE'" >> $OPTIONS_CFG
		fi
	done
fi

