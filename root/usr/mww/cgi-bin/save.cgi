#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

# redirect stderr to stdout so we see ouput in webif
exec 2>&1

update_inetd() {
	if [ -x /usr/bin/modinetd ]; then
		/usr/bin/modinetd --nosave "$1"
	fi
}

start_stop() {
	oldstatus=$2
	local rc="/mod/etc/init.d/rc.$1"
	if [ -x "$rc" ]; then
		status=$("$rc" status)
		if [ running = "$oldstatus" -a inetd = "$status" ]; then
			"$rc" stop
			update_inetd "$1"
			echo
		elif [ inetd = "$oldstatus" -a inetd != "$status" ]; then
			update_inetd "$1"
			"$rc" start
			echo
		elif [ inetd = "$oldstatus" -o inetd = "$status" ]; then
			update_inetd "$1"
			echo
		elif [ running = "$oldstatus" ]; then
			"$rc" restart
			echo
		fi
	fi
}

apply_changes() {
	echo
	if [ "$1" = mod ]; then
		start_stop telnetd "$2"
		start_stop webcfg "$3"
		start_stop swap "$4"
		. /mod/etc/conf/mod.cfg
		modunreg status mod mod/mounted
		modunreg status BOXinfo mod/box_info
		modunreg status FREETZinfo mod/info
		[ "$MOD_MOUNTED_SUB" = yes ] && modreg status mod '$(lang de:"Partitionen" en:"Partitions")' mod/mounted
		[ "$MOD_SHOW_BOX_INFO" = yes -a -r "/usr/lib/cgi-bin/mod/box_info.cgi" ] && modreg status BOXinfo 'BOX$(lang de:"-Info" en:" info")' mod/box_info
		[ "$MOD_SHOW_FREETZ_INFO" = yes -a -r "/usr/lib/cgi-bin/mod/info.cgi" ] && modreg status FREETZinfo 'FREETZ$(lang de:"-Info" en:" info")' mod/info
	else
		start_stop "$1" "$2"
	fi
}

rc_status() {
	local rc="/mod/etc/init.d/rc.$1"
	if [ -x "$rc" ]; then
		"$rc" status
	fi
}

# default functions for $package.save
pkg_pre_save() { :; }
pkg_apply_save() { :; }
pkg_post_save() { :; }
pkg_pre_def() { :; }
pkg_apply_def() { :; }
pkg_post_def() { :; }

cgi_begin "$(lang de:"Speichern" en:"Saving")..."

echo "<p>$(lang de:"Konfiguration speichern" en:"Saving settings"):</p>"
echo -n "<pre>"

form=$(cgi_param form | tr -d .)

script=status.cgi
package=''
oldstatus1=''
oldstatus2=''
oldstatus3=''

case $form in
	pkg_*)
		package=${form#pkg_}
		[ -r "/mod/etc/default.$package/$package.save" ] && . "/mod/etc/default.$package/$package.save"

		if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
			if [ "$package" = mod ]; then
				script=settings.cgi
				oldstatus1=$(rc_status telnetd)
				oldstatus2=$(rc_status webcfg)
				oldstatus3=$(rc_status swap)
			else
				script=pkgconf.cgi
				oldstatus1=$(rc_status "$package")
			fi
			prefix="$(echo "$package" | tr 'a-z\-' 'A-Z_')_"
			
			vars=''; delim=''
			for var in $(modconf vars "$package"); do
				vars="${vars}${delim}${var#$prefix}"
				delim=':'
			done

			settings=$(modcgi "$vars" "$package")
		fi

		pkg_pre_save | html

		if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
			echo -n 'Saving settings...'
			echo "$settings" | modconf set "$package" -
			echo 'done.'

			echo -n "Saving $package.cfg..."
			modconf save "$package"
			echo 'done.'
			
			{
			apply_changes "$package" "$oldstatus1" "$oldstatus2" "$oldstatus3"
			pkg_apply_save

			modsave flash
			} | html
		fi
		pkg_post_save | html
		;;
	def_*)
		package=${form#def_}
		[ -r "/mod/etc/default.$package/$package.save" ] && . "/mod/etc/default.$package/$package.save"
		pkg_pre_def | html

		if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
			if [ "$package" = mod ]; then 
				script=settings.cgi
				oldstatus1=$(rc_status telnetd)
                                oldstatus2=$(rc_status webcfg)
				oldstatus3=$(rc_status swap)
			else 
				script=pkgconf.cgi
                                oldstatus1=$(rc_status "$package")
                        fi
			
			echo -n 'Restoring defaults...'
			modconf default "$package"
			echo 'done.'

			{
			apply_changes "$package" "$oldstatus1" "$oldstatus2" "$oldstatus3"
			pkg_apply_def

			modsave flash
			} | html
		fi
		pkg_post_def | html
		;;
	*)
		echo "$(lang de:"Fehler: Unbekanntes Formular" en:"Error: unknown form") '$form'"
		;;
esac

echo '</pre>'
echo -n "<p><form action=\"/cgi-bin/$script\">"
echo -n "<input type=\"hidden\" name=\"pkg\" value=\"$package\">"
echo '<input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form></p>'

cgi_end
