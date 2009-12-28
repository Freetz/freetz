#!/bin/sh

DAEMON=php

. /etc/init.d/modlibrc

start() {
	[ ! -d /tmp/flash/php ] && mkdir /tmp/flash/php && mod_save=true
	if [ ! -f /tmp/flash/php.ini ]; then
		echo -n 'Setting up PHP ...'
		cp /etc/default.php/php.ini /tmp/flash/php.ini && mod_save=true
		if [ -n "$(ps w | grep lighttpd | grep -v grep)" ]; then
			/etc/init.d/rc.lighttpd restart
		fi
		echo 'done.'
	else
		echo 'Nothing to do here.'
	fi
	[ "$mod_save" == "true" ] && modsave flash >/dev/null
}

case "$1" in
	""|load)
		deffile='/mod/etc/default.php/php_config.def'
		[ -r /tmp/flash/php_config.def ] && deffile='/tmp/flash/php_config.def'
		modreg file 'php_config' 'PHP: php.ini' 0 "$deffile"
		;;
	unload)
		modlib_stop
		modunreg file 'php_config'
		;;
	start)
		start
		;;
	stop)
		;;
	restart)
		modlib_restart
		;;
	status)
		modlib_status
		;;
	*)
		echo "Usage: $0 [load|unload|start|stop|reload|restart|status]" 1>&2
		exit 1
		;;
esac

exit 0
