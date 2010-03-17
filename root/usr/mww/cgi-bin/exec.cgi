#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

eval "$(modcgi branding:pkg:cmd mod_cgi)"

case "$MOD_CGI_CMD" in
	start|stop|restart)
		if [ ! -x "/mod/etc/init.d/rc.$MOD_CGI_PKG" ]; then
			cgi_begin '$(lang de:"Fehler" en:"Error")'
			echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Kein Skript f&uuml;r" en:"no script for") '$MOD_CGI_PKG'</p>"
			cgi_end
			exit 1
		fi
		;;
esac
case "$MOD_CGI_CMD" in
	branding)
		cgi_begin '$(lang de:"Branding &auml;ndern" en:"Change branding")...'
		echo '<p>$(lang de:"Um die &Auml;nderungen wirksam zu machen, ist ein Neustart erforderlich." en:"You must reboot the device for the changes to take effect.")</p>'
		echo -n '<pre>set branding to '"'$MOD_CGI_BRANDING'"'...'
		success=0
		for i in $(ls /usr/www/); do
			case "$i" in
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
		back_button /cgi-bin/status.cgi
		cgi_end
		;;
	cleanup)
		cgi_begin '$(lang de:"Defragmentiere" en:"Clean up TFFS")...'
		echo -n '<pre>tffs cleanup...'
		echo 'cleanup' > /proc/tffs
		echo 'done.</pre>'
		back_button /cgi-bin/status.cgi
		cgi_end
		;;
	downgrade)
		cgi_begin 'Downgrade mod...'
		echo '<p>$(lang de:"Downgrade mod von supamicha" en:"Downgrade mod by supamicha"):<br>$(lang de:"&Auml;ndert die Firmware Version bis zum n&auml;chsten Neustart auf xx.01.01" en:"Changes the firmware version to xx.01.01 until next reboot")</p>'
		echo -n '<pre>Downgrading...'
		if [ -e /var/tmp/version ]; then
			echo 'already done.</pre>'
		else
			sed 's/{CONFIG_VERSION_MAJOR}.*/{CONFIG_VERSION_MAJOR}.01.01/1' /etc/version > /var/tmp/version
			chmod +x /var/tmp/version
			mount -o bind /var/tmp/version /etc/version
			echo 'done.</pre>'
		fi
		back_button /cgi-bin/status.cgi
		cgi_end
		;;
	firmware_update)
		cgi_begin '$(lang de:"Firmware-Update" en:"Firmware update")'
		/usr/lib/mww/firmware_update.cgi
		cgi_end
		;;
	external_update)
		cgi_begin '$(lang de:"external-Update" en:"external update")'
		/usr/lib/mww/external_update.cgi
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
		back_button /cgi-bin/status.cgi
		cgi_end
		;;
	restart_dsld)
		cgi_begin '$(lang de:"Starte dsld neu" en:"Restart dsld")...'
		echo -n '<pre>Stopping dsld...<br>'
		dsld -s
		sleep 3
		echo -n 'Restarting dsld...<br>'
		dsld -n
		echo -n 'done.</pre>'
		back_button /cgi-bin/status.cgi
		cgi_end
		;;
	reboot)
		cgi_begin '$(lang de:"Neustart" en:"Reboot")...'
		echo '<p>$(lang de:"Starte neu" en:"Rebooting")...</p>'
		echo '<p>$(lang de:"Nach dem Neustart <a href=\"/\" target=\"topframe\"><u>hier</u></a> wieder einloggen." en:"Login <a href=\"/\" target=\"topframe\"><u>here</u></a> after reboot.")</p>'
		cgi_end
		reboot
		;;
	start)
		cgi_begin "$(lang de:"Starte" en:"Starting") $MOD_CGI_PKG..."
		echo "<p>$(lang de:"Starte" en:"Starting") $MOD_CGI_PKG:</p>"
		echo -n '<pre>'
		/mod/etc/init.d/rc.$MOD_CGI_PKG start | html
		echo '</pre>'
		back_button /cgi-bin/daemons.cgi
		cgi_end
		;;
	stop)
		cgi_begin "$(lang de:"Stoppe" en:"Stopping") $MOD_CGI_PKG..."
		echo "<p>$(lang de:"Stoppe" en:"Stopping") $MOD_CGI_PKG:</p>"
		echo -n '<pre>'
		/mod/etc/init.d/rc.$MOD_CGI_PKG stop | html
		echo '</pre>'
		back_button /cgi-bin/daemons.cgi
		cgi_end
		;;
	restart)
		cgi_begin "$(lang de:"Starte $MOD_CGI_PKG neu" en:"Restarting $MOD_CGI_PKG")..."
		echo "<p>$(lang de:"Starte $MOD_CGI_PKG neu" en:"Restarting $MOD_CGI_PKG"):</p>"
		echo -n '<pre>'
		/mod/etc/init.d/rc.$MOD_CGI_PKG restart | html
		echo '</pre>'
		back_button /cgi-bin/daemons.cgi
		cgi_end
		;;
	*)
		cgi_begin '$(lang de:"Fehler" en:"Error")'
		echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Unbekannter Befehl" en:"unknown command") '$MOD_CGI_CMD'</p>"
		cgi_end
		;;
esac
