#!/bin/sh

. /usr/lib/libmodcgi.sh

trim_string()
{
trimmed=$1
trimmed=${trimmed%%}
trimmed=${trimmed##}
echo $trimmed
}

#

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cgi_print_radiogroup_service_starttype "enabled" "$NZBGET_ENABLED" "" "" 0

sec_end

#

NZBGET_PORT=$(grep -i "^ControlPort" /mod/nzbget/nzbget.conf | cut -d "=" -f2 | sed 's/^ //')
HOST_IP=$(trim_string $(hostname -i))

sec_begin '$(lang de:"Webinterface" en:"Web interface")'
	if [ "$(/mod/etc/init.d/rc.nzbget status)" = 'stopped' ]; then
		echo '<h2>$(lang de:"NZBGet wurde nicht gestartet!" en:"NZBGet isn't started!")</h2>'
	else
		if [ -z "$NZBGET_PORT" ]; then
			echo '<h2>$(lang de:"NZBGet-Webinterface nicht aktiv!" en:"NZBGet web interface isn't aktiv!")</h2>'
		else
			echo '<ul><li><a href="http://'$HOST_IP':'$NZBGET_PORT'/" target="_blank">$(lang de:"Anzeigen" en:"Show")</a></li></ul>'
		fi
	fi
sec_end

#

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cgi_print_textline_p "configdir" "$NZBGET_CONFIGDIR" 55/255 "$(lang de:"NZBGet Verzeichnis" en:"NZBGet directory"): "

sec_end

#
