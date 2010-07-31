#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
source /usr/lib/libmodcgi.sh

update_inetd() {
	if [ -x /usr/bin/modinetd ]; then
		/usr/bin/modinetd --nosave "$1"
	fi
}

start_stop() {
	local startORstop=$1
	local package=$2
	local oldstatus=$3
	local rc="/mod/etc/init.d/rc.${4-$2}"
	[ ! -x "$rc" ] && return
	case "$startORstop" in
		start)
			local newstatus=$(rc_status ${4-$2})
			[ "$oldstatus" == inetd -o "$newstatus" == inetd ] && update_inetd "$package"
			[ "$oldstatus" != stopped -a "$newstatus" != inetd ] && "$rc" start
			;;
		stop)
			[ "$oldstatus" == running ] && "$rc" stop
			;;
	esac
}

apply_changes() {
	local startORstop=$1
	local package=$2
	if [ "$package" = mod ]; then
		start_stop $startORstop telnetd "$OLDSTATUS_telnetd"
		start_stop $startORstop webcfg "$OLDSTATUS_webcfg"
		start_stop $startORstop swap "$OLDSTATUS_swap"
		/usr/lib/mod/reg-status reload
	else
		start_stop $startORstop "$package" "$OLDSTATUS_PACKAGE"
	fi
}

rc_status() {
	local rc="/mod/etc/init.d/rc.$1"
	if [ -x "$rc" ]; then
		"$rc" status
	fi
}

path_info package _
if ! valid package "$package"; then
	cgi_error "$package: $(lang de:"Unbekanntes Paket" en:"Unknown package")"
	exit
fi

default=false
case $QUERY_STRING in
    	*default*) default=true ;;
esac

cgi_begin "$(lang de:"Speichern" en:"Saving")..."

if $default; then
	echo "<p>$(lang de:"Konfiguration zurücksetzen" en:"Restore default settings") ($package):</p>"
else
	echo "<p>$(lang de:"Konfiguration speichern" en:"Saving settings") ($package):</p>"
fi
echo -n "<pre>"

# redirect stderr to stdout so we see output in webif
exec 2>&1

back="mod status"
unset OLDSTATUS_telnetd OLDSTATUS_webcfg OLDSTATUS_swap

if $default; then
    hook=def
else
    hook=save
fi

# default functions for $package.save
pkg_pre_save() { :; }
pkg_apply_save() { :; }
pkg_post_save() { :; }
pkg_pre_def() { :; }
pkg_apply_def() { :; }
pkg_post_def() { :; }

# load package's implementation of these functions
if [ -r "/mod/etc/default.$package/$package.save" ]; then
	source "/mod/etc/default.$package/$package.save"
fi

if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
	if [ "$package" = mod ]; then
		back="mod conf"
		OLDSTATUS_telnetd=$(rc_status telnetd)
		OLDSTATUS_webcfg=$(rc_status webcfg)
		OLDSTATUS_swap=$(rc_status swap)
	else
		back="cgi $package"
		OLDSTATUS_PACKAGE=$(rc_status "$package")
	fi
	if ! $default; then
		prefix="$(echo "$package" | tr 'a-z\-' 'A-Z_')_"

		unset vars
		for var in $(modconf vars "$package"); do
			vars="${vars:+$vars:}${var#$prefix}"
		done

		settings=$(modcgi "$vars" "$package")
	fi
fi

pkg_pre_$hook | html

if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
	apply_changes stop "$package"
	echo
	if ! $default; then
		echo -n 'Saving settings...'
		echo "$settings" | modconf set "$package" -
		echo 'done.'
		echo -n "Saving $package.cfg..."
		modconf save "$package"
		echo 'done.'
	else
		echo -n 'Restoring defaults...'
		modconf default "$package"
		echo 'done.'
	fi
	echo
	{
		apply_changes start "$package"
		pkg_apply_$hook
		echo
		modsave flash
	} | html
fi

pkg_post_$hook | html

echo '</pre>'
back_button $back

cgi_end
