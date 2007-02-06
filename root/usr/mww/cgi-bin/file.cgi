#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

[ -e "/mod/etc/reg/file.reg" ] || touch /mod/etc/reg/file.reg

id="$(echo "$QUERY_STRING" | sed -e 's/^.*id=//' -e 's/&.*$//' -e 's/\.//g')"

cgi_begin "$id" "file_$id"

sec_level=1
[ -r "/tmp/flash/security" ] && let sec_level="$(cat /tmp/flash/security)"

OIFS="$IFS"
IFS='|'
set -- $(cat /mod/etc/reg/file.reg | grep "^$id|")
IFS="$OIFS"

# Defaults
TEXT_ROWS=18

# Load config
[ -r "$4" ] && . $4

echo "<h1>$CAPTION</h1>"
[ -n "$DESCRIPTION" ] && echo "<p>$DESCRIPTION</p>"

if [ -z "$CONFIG_FILE" -o "$sec_level" -gt "$3" ]; then
	echo '<div style="color: #800000;">$(lang de:"Konfiguration in der aktuellen Sicherheitsstufe nicht verf&uuml;gbar!" en:"Settings are not available at current security level!")</div>'

	case "$CONFIG_TYPE" in
		text)
			echo -n '<p><textarea style="width: 500px;" name="content" rows="'"$TEXT_ROWS"'" cols="60" readonly>'
			[ -r "$CONFIG_FILE" ] && httpd -e "$(cat $CONFIG_FILE)"
			echo '</textarea></p>'
			;;
		list)
			;;
		*)
			echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Unbekannter Typ" en:"unknown type") '$CONFIG_TYPE'</p>"
			;;
	esac
else
	case "$CONFIG_TYPE" in
		text)
			echo "<form action=\"/cgi-bin/save.cgi?form=file_$id\" method=\"post\">"
			echo -n '<textarea style="width: 500px;" name="content" rows="'"$TEXT_ROWS"'" cols="60">'
			[ -r "$CONFIG_FILE" ] && httpd -e "$(cat $CONFIG_FILE)"
			echo '</textarea>'
			echo '<div class="btn"><input type="submit" value="$(lang de:"&Uuml;bernehmen" en:"Apply")"></div>'
			echo '</form>'
			;;
		list)
			;;
		*)
			echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Unbekannter Typ" en:"unknown type") '$CONFIG_TYPE'</p>"
			;;
	esac
fi

cgi_end
