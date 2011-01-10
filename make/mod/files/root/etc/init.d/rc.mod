#!/bin/sh

## Store 'clean' environment for later use
# overwrite AVM's version
env - /bin/sh -c 'VERBOSE_RC_CONF=n; . /etc/init.d/rc.conf; unset PWD; env' | sed -re 's/^([^=]+)=(.*)$/export \1='"'\2'"/ > /var/env.cache

DAEMON=mod
. /etc/init.d/modlibrc

start() {
	echo "rc.mod version $(cat /etc/.freetz-version)"

	# Basic Packages
	for pkg in crond swap telnetd webcfg external websrv dsld ftpd smbd multid; do
		local pkg_default=/etc/default.$pkg
		[ -d "$pkg_default" -a ! -e "/mod${pkg_default}" ] && ln -s "$pkg_default" "/mod${pkg_default}"
		local rc="/etc/init.d/rc.$pkg"
		[ -e "$rc" -a ! -e "/mod$rc" ] && ln -s "$rc" "/mod$rc"
	done

	[ -d /tmp/flash ] || /usr/bin/modload

	for pkg in crond telnetd webcfg swap external dsld multid ftpd; do
		local rc="/etc/init.d/rc.$pkg"
		[ -x "$rc" ] && "$rc"
	done

	# Static Packages
	if [ -x /etc/init.d/rc.external -a "$MOD_EXTERNAL_FREETZ_SERVICES" == "yes" ]; then
		EXTERNAL_SERVICES=" $(cat /etc/external.pkg 2>/dev/null) $MOD_EXTERNAL_OWN_SERVICES "
	fi
	for pkg in $(cat /etc/static.pkg 2>/dev/null); do
		[ "$pkg" = mod ] && continue
		if [ -x "/etc/init.d/rc.$pkg" ]; then
			if echo "$EXTERNAL_SERVICES" | grep -q " $pkg "; then
				echo "$pkg will be started by external."
			else
				"/etc/init.d/rc.$pkg"
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

	#compat (may be removed later):
	[ -r /tmp/flash/rc.custom ] && mv /tmp/flash/rc.custom /tmp/flash/mod/rc.custom
	[ -r /tmp/flash/mod/rc.custom ] && . /tmp/flash/mod/rc.custom

	[ -x /etc/init.d/rc.external ] && touch /tmp/.modstarted

	/usr/lib/mod/menu-update
}

modreg_file() {
	local file=$1 sec_level=$2
	local basename=${file//./_}
	modreg file mod "$basename" "$file" "$sec_level" "$basename"
}

register() {
	modreg cgi mod "Freetz"
	modreg conf mod webcfg "$(lang de:"Weboberfläche" en:"Web interface")"
	modreg conf mod avm "AVM $(lang de:"Dienste" en:"services")"

	modreg_file  .profile    0
	modreg_file  hosts       1
	modreg_file  modules     0
	modreg_file  rc.custom   0

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
	*)
		echo "Usage: $0 [start]" 1>&2
		exit 1
		;;
esac
