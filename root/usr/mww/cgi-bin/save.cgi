#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

save_flash() {
	if modsave flash; then
		if [ -x "/mod/etc/init.d/rc.$1" ]; then
			if [ "$(/mod/etc/init.d/rc.$1 status)" = "running" ]; then
				echo
				/mod/etc/init.d/rc.$1 restart
			fi
		fi
	fi
}

cgi_begin "$(lang de:"Speichern" en:"Saving")..."

echo "<p>$(lang de:"Konfiguration speichern" en:"Saving settings"):</p>"
echo -n "<pre>"

form="$(echo "$QUERY_STRING" | sed -e 's/^.*form=//' -e 's/&.*$//' -e 's/\.//g')"

script='status.cgi';
package=''
file_id=''

case "$form" in
	pkg_*)
		package="${form#pkg_}"
		if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
			if [ "$package" = "mod" ]; then script='settings.cgi'; else script="pkgconf.cgi"; fi
			prefix="$(echo "$package" | tr 'a-z\-' 'A-Z_')_"

			vars=''; delim=''
			for var in $(modconf vars $package); do
				vars="${vars}${delim}${var#$prefix}"
				delim=':'
			done

			echo -n 'Saving settings...'
			modcgi $vars $package | modconf set $package -
			echo 'done.'

			echo -n "Saving $package.cfg..."
			modconf save $package
			echo 'done.'

			save_flash $package
		fi
		;;
	def_*)
		package="${form#def_}"
		if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
			if [ "$package" = "mod" ]; then script='settings.cgi'; else script="pkgconf.cgi"; fi

			echo -n 'Restoring defaults...'
			modconf default $package
			echo 'done.'

			save_flash $package
		fi
		;;
	file_*)
		file_id="${form#file_}"
		script='file.cgi'

		[ -e "/mod/etc/reg/file.reg" ] || touch /mod/etc/reg/file.reg

		sec_level=1
		[ -r "/tmp/flash/security" ] && let sec_level="$(cat /tmp/flash/security)"

		OIFS="$IFS"
		IFS='|'
		set -- $(cat /mod/etc/reg/file.reg | grep "^$file_id|")
		IFS="$OIFS"

		[ -r "$4" ] && . $4

		if [ -z "$CONFIG_FILE" -o "$sec_level" -gt "$3" ]; then
			echo "Configuration file not available at the current security level!"
		else
			case "$CONFIG_TYPE" in
				text)
					eval "$(modcgi content mod_cgi)"
					echo -n "Saving $file_id..."
					echo "$MOD_CGI_CONTENT" > $CONFIG_FILE
					echo 'done.'
					eval "$CONFIG_SAVE"
					;;
				list)
					eval "$CONFIG_SAVE"
					;;
			esac
		fi
		;;
	*)
		echo "$(lang de:"Fehler: Unbekanntes Formular" en:"Error: unknown form") '$form'"
		;;
esac

echo '</pre>'
echo -n "</p><form action=\"/cgi-bin/$script\">"
[ -z "$package" ] || echo -n "<input type=\"hidden\" name=\"pkg\" value=\"$package\">"
[ -z "$file_id" ] || echo -n "<input type=\"hidden\" name=\"id\" value=\"$file_id\">"
echo '<input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form></p>'

cgi_end
