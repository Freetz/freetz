#!/bin/sh

## Store 'clean' environment for later use
# overwrite AVM's version
env - /bin/sh -c 'VERBOSE_RC_CONF=n; . /etc/init.d/rc.conf; unset PWD; env' | sed -re 's/^([^=]+)=(.*)$/export \1='"'\2'"/ > /var/env.cache

DAEMON=mod
. /etc/init.d/modlibrc

log() {
	[ "$*" == "" ] && return
	echo "$*"
	logger -t FREETZMOD "$*"
}

start() {
	log "rc.mod version $(cat /etc/.freetz-version)"

	if [ ! -e /tmp/flash/mod/dont_touch_https ]; then
		ctlmgr_ctl w remoteman settings/enabled 0 >/dev/null 2>&1
		log "Disabled remote https access."
	fi

	# Basic Packages
	for pkg in crond telnetd webcfg dsld ftpd multid swap external websrv smbd; do
		local pkg_default=/etc/default.$pkg
		[ -d "$pkg_default" -a ! -e "/mod${pkg_default}" ] && ln -s "$pkg_default" "/mod${pkg_default}"
		local rc="/etc/init.d/rc.$pkg"
		[ -e "$rc" -a ! -e "/mod$rc" ] && ln -s "$rc" "/mod$rc"
	done

	[ -d /tmp/flash ] || /usr/bin/modload

	# set ipv6
	if [ -e /usr/lib/cgi-bin/mod/conf/80-ipv6.sh -a -d /proc/sys/net/ipv6 ]; then
		echo "$MOD_IPV6_ASSIGN" | grep -v "^ *#" | while read -r if6 ip6; do
			[ -n "$if6" -a -n "$ip6" ] && ifconfig $if6 $ip6
		done
		[ "$MOD_IPV6_FORWARD" == "yes" ] && echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
	fi

	for pkg in crond telnetd webcfg dsld ftpd multid swap external websrv; do
		local rc="/etc/init.d/rc.$pkg"
		[ -x "$rc" ] && log "$($rc)"
	done

	# Static Packages
	if [ -x /etc/init.d/rc.external ]; then
		[ "$MOD_EXTERNAL_FREETZ_SERVICES" == "yes" ] && EXTERNAL_SERVICES="$(cat /etc/external.pkg 2>/dev/null)"
		EXTERNAL_SERVICES=" $EXTERNAL_SERVICES $MOD_EXTERNAL_OWN_SERVICES "
	fi
	for pkg in $(cat /etc/static.pkg 2>/dev/null); do
		[ "$pkg" = mod ] && continue
		local rc="/etc/init.d/rc.$pkg"
		if [ -x "$rc" ]; then
			if echo "$EXTERNAL_SERVICES" | grep -q " $pkg "; then
				log "$pkg will be started by external."
			else
				log "$($rc)"
			fi
		fi
	done

	# AVM-Plugins
	plugins=$(ls /var/plugin-*/control 2>/dev/null)
	if [ -n "$plugins" ]; then
		echo -n "Starting AVM-Plugins"
		for plugin in $plugins; do
			echo -n " ... $(echo $plugin | sed 's/.*plugin-//;s/\/.*//')"
			$plugin start >/dev/null 2>&1
			[ $? -ne 0 ] && echo -n "(failed)"
		done
		echo " ... done."
	fi

	if [ -r /tmp/flash/mod/rc.custom ]; then
		echo -n "Starting rc.custom ... "
		sh /tmp/flash/mod/rc.custom 0</dev/null 1>/var/log/rc_custom.log 2>&1
		echo "done."
	fi

	touch /tmp/.modstarted

	# 7390: external hook for nand flash, if NAND exists it is mounted under /var/media/ftp
	if [ "$CONFIG_NAND" = 'y' -a -f "$MOD_EXTERNAL_DIRECTORY"/.external ] &&
		df -P "$MOD_EXTERNAL_DIRECTORY" | tail -n1 | grep -q " /var/media/ftp$"; then
		log "external detected on nand."
		/etc/init.d/rc.external start
	 fi

	/usr/lib/mod/menu-update

	log "rc.mod finished."
}

stop_helper() {
	for pkg in $*; do
		[ "$pkg" = mod ] && continue
		local rc="/etc/init.d/rc.$pkg"
		[ -x "$rc" ] && log "$pkg: $($rc stop)"
	done
}

stop() {
	log "Stopping all packages:"

	[ -n "$MOD_SHUTDOWN_FIRST" ] && stop_helper $MOD_SHUTDOWN_FIRST

	local all_packages=""
	for pkg in $(cat /etc/static.pkg 2>/dev/null) crond telnetd webcfg dsld ftpd multid; do
		if ! echo " $MOD_SHUTDOWN_FIRST $MOD_SHUTDOWN_IGNORE $MOD_SHUTDOWN_LAST " | grep -q " $pkg "; then
			all_packages="$all_packages $pkg"
		fi
	done
	stop_helper $all_packages

	[ -n "$MOD_SHUTDOWN_LAST" ] && stop_helper $MOD_SHUTDOWN_LAST

	log "Stopping all packages finished."
}

modreg_file() {
	local file=$1 sec_level=$2
	local basename=${file//./_}
	modreg file mod "$basename" "$file" "$sec_level" "$basename"
}

register() {
	AUML="$(echo -ne '\344')"

	modreg cgi mod "Freetz"
	modreg conf mod webcfg "$(lang de:"Weboberfl${AUML}che" en:"Web interface")"
	modreg cgi avm "$(lang de:"AVM-Dienste" en:"AVM services")"

	modreg_file  .profile    0
	modreg_file  hosts       1
	modreg_file  modules     0
	modreg_file  rc.custom   0
	modreg_file  shutdown    0
	[ -h /usr/bin/dtrace ] && modreg_file dtrace 0
	[ -h /etc/udev/rules.d/00-custom.rules ] && modreg_file udev_first 0
	[ -h /etc/udev/rules.d/99-custom.rules ] && modreg_file udev_final 0

	/usr/lib/mod/reg-status start
}

case $1 in
	"")
		register
		start
		;;
	start)
		start
		;;
	stop)
		stop
		;;
	*)
		echo "Usage: $0 [start|stop]" 1>&2
		exit 1
		;;
esac
