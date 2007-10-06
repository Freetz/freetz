#!/bin/sh

cd /
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/mod/sbin:/mod/bin:/mod/usr/sbin:/mod/usr/bin
export LD_LIBRARY_PATH=/mod/lib:/mod/usr/lib
export TERM=xterm

start() {
	echo "rc.mod version $(cat /etc/.subversion)"

	# Basic Packages
	[ -e "/mod/etc/init.d/rc.crond" ] || ln -s /etc/init.d/rc.crond /mod/etc/init.d/rc.crond
	[ -e "/mod/etc/init.d/rc.swap" ] || ln -s /etc/init.d/rc.crond /mod/etc/init.d/rc.swap
	[ -e "/mod/etc/init.d/rc.telnetd" ] || ln -s /etc/init.d/rc.telnetd /mod/etc/init.d/rc.telnetd
	[ -e "/mod/etc/init.d/rc.webcfg" ] || ln -s /etc/init.d/rc.webcfg /mod/etc/init.d/rc.webcfg
	[ -e "/mod/etc/init.d/rc.websrv" ] || ln -s /etc/init.d/rc.websrv /mod/etc/init.d/rc.websrv

	[ -d "/tmp/flash" ] || /usr/bin/modload

	/etc/init.d/rc.crond
	/etc/init.d/rc.telnetd
	/etc/init.d/rc.webcfg

	if [ -e "/etc/static.pkg" ]; then
		for pkg in $(cat /etc/static.pkg); do
			[ -x "/etc/init.d/rc.$pkg" ] && /etc/init.d/rc.$pkg
		done
	fi

	[ -r "/tmp/flash/rc.custom" ] && . /tmp/flash/rc.custom
	
	# give swapfile some time
	/etc/init.d/rc.swap
}

case "$1" in
	"")
		deffile='/etc/default.mod/exhosts.def'
		[ -r "/tmp/flash/exhosts.def" ] && deffile='/tmp/flash/exhosts.def'
		modreg file 'exhosts' 'Hosts' 1 "$deffile"

		start
		;;
	start)
		start
		;;
	*)
		echo "Usage: $0 [start]" 1>&2
		exit 1
		;;
esac
