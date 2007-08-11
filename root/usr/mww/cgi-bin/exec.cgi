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
				all|cgi-bin|html)
					;;
				*)
					if [ "$i" = "$MOD_CGI_BRANDING" ]; then
						echo "firmware_version $i" > /proc/avalanche/env
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
		echo '<form action="/cgi-bin/status.cgi"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form>'
		cgi_end
		;;
	cleanup)
		cgi_begin '$(lang de:"Defragmentiere" en:"Cleanup tffs")...'
		echo -n '<pre>tffs cleanup...'
		echo 'cleanup' > /proc/tffs
		echo 'done.</pre>'
		echo '<form action="/cgi-bin/status.cgi"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form>'
		cgi_end
		;;
	downgrade)
		cgi_begin 'Downgrade mod...'
		echo '<p>$(lang de:"Downgrade mod von supamicha" en:"Downgrade mod by supamicha"):<br>$(lang de:"&Auml;ndert die Firmware Version bis zum n&auml;chsten Neustart auf xx.01.01" en:"Changes the firmware version to xx.01.01 until next reboot")</p>'
		echo -n '<pre>Downgrading...'
		if [ -e "/var/tmp/version" ]; then
			echo 'already done.</pre>'
		else
			sed 's/{CONFIG_VERSION_MAJOR}.*/{CONFIG_VERSION_MAJOR}.01.01/1' /etc/version > /var/tmp/version
			chmod +x /var/tmp/version
			mount -o bind /var/tmp/version /etc/version
			echo 'done.</pre>'
		fi
		echo '<form action="/cgi-bin/status.cgi"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form>'
		cgi_end
		;;
	reboot)
		cgi_begin '$(lang de:"Neustart" en:"Reboot")...'
		echo '<p>$(lang de:"Starte neu" en:"Rebooting")...</p>'
		echo '<p>$(lang de:"Nach dem Neustart <a href=\"/\" target=\"topframe\">hier</a> wieder einloggen." en:"Login <a href=\"/\" target=\"topframe\">here</a> after reboot.")</p>'
		cgi_end
		reboot
		;;
	start)
		cgi_begin "$(lang de:"Starte" en:"Starting") $MOD_CGI_PKG..."
		echo "<p>$(lang de:"Starte" en:"Starting") $MOD_CGI_PKG:</p>"
		echo -n '<pre>'
		/mod/etc/init.d/rc.$MOD_CGI_PKG start
		echo '</pre>'
		echo '<form action="/cgi-bin/daemons.cgi"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form>'
		cgi_end
		;;
	stop)
		cgi_begin "$(lang de:"Stoppe" en:"Stopping") $MOD_CGI_PKG..."
		echo "<p>$(lang de:"Stoppe" en:"Stopping") $MOD_CGI_PKG:</p>"
		echo -n '<pre>'
		/mod/etc/init.d/rc.$MOD_CGI_PKG stop
		echo '</pre>'
		echo '<form action="/cgi-bin/daemons.cgi"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form>'
		cgi_end
		;;
	restart)
		cgi_begin "$(lang de:"Starte $MOD_CGI_PKG neu" en:"Restarting $MOD_CGI_PKG")..."
		echo "<p>$(lang de:"Starte $MOD_CGI_PKG neu" en:"Restarting $MOD_CGI_PKG"):</p>"
		echo -n '<pre>'
		/mod/etc/init.d/rc.$MOD_CGI_PKG restart
		echo '</pre>'
		echo '<form action="/cgi-bin/daemons.cgi"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form>'
		cgi_end
		;;
	*)
		cgi_begin '$(lang de:"Fehler" en:"Error")'
		echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Unbekannter Befehl" en:"unknown command") '$MOD_CGI_CMD'</p>"
		cgi_end
		;;
esac
