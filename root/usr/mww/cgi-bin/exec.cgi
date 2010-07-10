#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
REG=/mod/etc/reg/daemon.reg

eval "$(modcgi branding:daemon:cmd mod_cgi)"

case $MOD_CGI_CMD in
	start|stop|restart)
		case $MOD_CGI_DAEMON in
			*/*|*..*) exit 2 ;;
		esac
		# retrieve package information
		OIFS=$IFS; IFS="|"
		set -- $(grep "^$MOD_CGI_DAEMON|" "$REG")
		IFS=$OIFS
		if [ $# -gt 0 ]; then
			name=$2
			rcfile=${3:+/mod/etc/init.d/$3}
		else
			# fallback (for base packages and AVM services)
			name=$MOD_CGI_DAEMON
			rcfile="/mod/etc/init.d/rc.$MOD_CGI_DAEMON"
		fi
		if [ ! -x "$rcfile" ]; then
			cgi_begin '$(lang de:"Fehler" en:"Error")'
			echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Kein Skript f&uuml;r" en:"no script for") '${name:-$MOD_CGI_DAEMON}'</p>"
			cgi_end
			exit 1
		fi
		;;
esac
case $MOD_CGI_CMD in
	branding)
		cgi_begin '$(lang de:"Branding &auml;ndern" en:"Change branding")...'
		echo '<p>$(lang de:"Um die &Auml;nderungen wirksam zu machen, ist ein Neustart erforderlich." en:"You must reboot the device for the changes to take effect.")</p>'
		echo -n '<pre>set branding to '"'$MOD_CGI_BRANDING'"'...'
		success=0
		for i in $(ls /usr/www/); do
			case $i in
				all|cgi-bin|html|kids)
					;;
				*)
					if [ "$i" = "$MOD_CGI_BRANDING" ]; then
						echo "firmware_version $i" > /proc/sys/urlader/environment
						success=1
					fi
					;;
			esac
		done
		if [ "$success" -eq 1 ]; then
			echo 'done.</pre>'
		else
			echo 'failed.</pre>'
		fi
		back_button mod status
		cgi_end
		;;
	cleanup)
		cgi_begin '$(lang de:"Defragmentiere" en:"Clean up TFFS")...'
		echo -n '<pre>tffs cleanup...'
		echo 'cleanup' > /proc/tffs
		echo 'done.</pre>'
		back_button mod status
		cgi_end
		;;
	fw_attrib)
		cgi_begin '$(lang de:"Attribute bereinigen" en:"Clean up attributes")'
		echo '<p>$(lang de:"Entfernt Merker f&uuml;r \"nicht unterst&uuml;tzte &Auml;nderungen\"" en:"Cleans up marker for \"unauthorized changes\"")</p>'
		echo -n '<pre>$(lang de:"Bereinige Attribute" en:"Cleaning up attributes")...'
		major=$(grep tffs /proc/devices)
		tffs_major=${major%%tffs}
		rm -f /var/flash/fw_attrib
		mknod /var/flash/fw_attrib c $tffs_major 87
		echo -n "" > /var/flash/fw_attrib
		rm -f /var/flash/fw_attrib
		echo ' $(lang de:"fertig" en:"done").</pre>'
		back_button mod status
		cgi_end
		;;
	reboot)
		cgi_begin '$(lang de:"Neustart" en:"Reboot")...'
		echo '<p>$(lang de:"Starte neu" en:"Rebooting")...</p>'
		echo '<p>$(lang de:"Nach dem Neustart <a href=\"/\" target=\"_top\"><u>hier</u></a> wieder einloggen." en:"Login <a href=\"/\" target=\"_top\"><u>here</u></a> after reboot.")</p>'
		cgi_end
		reboot
		;;
	start|stop|restart)
		cmd=$MOD_CGI_CMD
		case $cmd in
			start)   message="$(lang de:"Starte" en:"Starting") $name" ;;
			stop)    message="$(lang de:"Stoppe" en:"Stopping") $name" ;;
			restart) message="$(lang de:"Starte $name neu" en:"Restarting $name")" ;;
		esac
		cgi_begin "$message ..."
		echo -n "<p>$message:</p><pre>"
		"$rcfile" "$cmd" | html
		echo '</pre>'
		back_button mod daemons
		cgi_end
		;;
	*)
		cgi_begin '$(lang de:"Fehler" en:"Error")'
		echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Unbekannter Befehl" en:"unknown command") '$MOD_CGI_CMD'</p>"
		cgi_end
		;;
esac
