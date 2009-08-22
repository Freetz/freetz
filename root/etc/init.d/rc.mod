#!/bin/sh

cd /
export TERM=xterm

. /etc/init.d/modlibrc

start() {
	echo "rc.mod version $(cat /etc/.freetz-version)"

	# Basic Packages
	for pkg in crond swap telnetd webcfg websrv; do
		rc="/etc/init.d/rc.$pkg"
		[ -e "/mod$rc" ] || ln -s "$rc" "/mod$rc"
	done

	[ -d /tmp/flash ] || /usr/bin/modload

	[ -r /tmp/flash/mod/resolv.conf ] || cat /var/tmp/resolv.conf>/tmp/flash/mod/resolv.conf

	/etc/init.d/rc.crond
	/etc/init.d/rc.telnetd
	/etc/init.d/rc.webcfg

	# Static Packages
	if [ -e /etc/static.pkg ]; then
		for pkg in $(cat /etc/static.pkg); do
			[ -x "/etc/init.d/rc.$pkg" ] && "/etc/init.d/rc.$pkg"
		done
	fi

	# AVM-Plugins
	plugins="`ls /var/plugin-*/control 2>/dev/null`"
	if [ -n "$plugins" ]; then
		echo -n "Starting AVM-Plugins"
		for plugin in "$plugins"; do
			echo -n "...`echo $plugin|sed 's/.*plugin-//;s/\/.*//'`"
			$plugin start 2>&1 >/dev/null
			[ $? -ne 0 ] && echo -n "(failed)"
		done
		echo "...done."
	fi

	[ -r /tmp/flash/rc.custom ] && mv /tmp/flash/rc.custom /tmp/flash/mod/rc.custom
	[ -r /tmp/flash/mod/rc.custom ] && . /tmp/flash/mod/rc.custom

	/etc/init.d/rc.swap
}

case "$1" in
	"")

		deffile='/etc/default.mod/_profile.def'
		[ -r /tmp/flash/mod/_profile.def ] && deffile='/tmp/flash/mod/_profile.def'
		modreg file 'Freetz___profile' 'Freetz: .profile' 0 "$deffile"

		deffile='/etc/default.mod/hosts.def'
		[ -r /tmp/flash/mod/hosts.def ] && deffile='/tmp/flash/mod/hosts.def'
		modreg file 'Freetz__hosts' 'Freetz: hosts' 1 "$deffile"

		deffile='/etc/default.mod/modules.def'
		[ -r /tmp/flash/mod/modules.def ] && deffile='/tmp/flash/mod/modules.def'
		modreg file 'Freetz__modules' 'Freetz: modules' 0 "$deffile"

		deffile='/etc/default.mod/resolv_conf.def'
		[ -r /tmp/flash/mod/resolv_conf.def ] && deffile='/tmp/flash/mod/resolv_conf.def'
		modreg file 'Freetz__resolv_conf' 'Freetz: resolv.conf' 0 "$deffile"

		deffile='/etc/default.mod/rc_custom.def'
		[ -r /tmp/flash/mod/rc_custom.def ] && deffile='/tmp/flash/mod/rc_custom.def'
		modreg file 'Freetz__rc_custom' 'Freetz: rc.custom' 0 "$deffile"

		[ -r "/mod/etc/conf/mod.cfg" ] && . /mod/etc/conf/mod.cfg
		modreg status mod '$(lang de:"Logdateien" en:"Logfiles")' mod/logs
		[ "$MOD_MOUNTED_SUB" = yes ] && modreg status mod '$(lang de:"Partitionen" en:"Partitions")' mod/mounted
		modreg status infos '$(lang de:"Informationen" en:"Information")' mod/infos

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
