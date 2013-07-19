#!/bin/sh

DAEMON=php


case $1 in
	""|load)
		[ ! -d /tmp/flash/$DAEMON ] && mkdir -p /tmp/flash/$DAEMON
		[ ! -e /tmp/flash/php.ini ] && cat /mod/etc/default.$DAEMON/php.ini > /tmp/flash/php.ini

		modreg daemon --hide $DAEMON
		modreg file $DAEMON config 'php.ini' 0 "php_config"
		;;
	unload)
		modunreg file $DAEMON
		modunreg daemon $DAEMON
		;;
	*)
		echo "Usage: $0 [load|unload]" 1>&2
		exit 1
		;;
esac

exit 0
