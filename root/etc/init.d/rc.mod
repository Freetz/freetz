#!/bin/sh

cd /
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/mod/sbin:/mod/bin:/mod/usr/sbin:/mod/usr/bin
export LD_LIBRARY_PATH=/mod/lib:/mod/usr/lib
export TERM=xterm

start() {
	echo "rc.mod version $(cat /etc/.freetz-version)"

	# Basic Packages
	for pkg in crond swap telnetd webcfg websrv; do
		rc="/etc/init.d/rc.$pkg"
		[ -e "/mod$rc" ] || ln -s "$rc" "/mod$rc"
	done

	[ -d /tmp/flash ] || /usr/bin/modload

	/etc/init.d/rc.crond
	/etc/init.d/rc.telnetd
	/etc/init.d/rc.webcfg

	if [ -e /etc/static.pkg ]; then
		for pkg in $(cat /etc/static.pkg); do
			[ -x "/etc/init.d/rc.$pkg" ] && "/etc/init.d/rc.$pkg"
		done
	fi

	[ -r /tmp/flash/rc.custom ] && . /tmp/flash/rc.custom

	/etc/init.d/rc.swap
}

case "$1" in
	"")
		deffile='/etc/default.mod/exhosts.def'
		[ -r /tmp/flash/exhosts.def ] && deffile='/tmp/flash/exhosts.def'
		modreg file 'exhosts' 'Hosts' 1 "$deffile"

		deffile='/etc/default.mod/rc_custom.def'
		[ -r /tmp/flash/rc_custom.def ] && deffile='/tmp/flash/rc_custom.def'
		modreg file 'rc_custom' 'rc.custom' 0 "$deffile"

		deffile='/etc/default.mod/modules.def'
		[ -r /tmp/flash/modules.def ] && deffile='/tmp/flash/modules.def'
		modreg file 'modules' 'modules' 0 "$deffile"

		[ -r "/mod/etc/conf/mod.cfg" ] && . /mod/etc/conf/mod.cfg
		modreg status mod '$(lang de:"Logdateien" en:"Logfiles")' mod/logs
		[ "$MOD_MOUNTED_SUB" = yes ] && modreg status mod '$(lang de:"Partitionen" en:"Partitions")' mod/mounted

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
