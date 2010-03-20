#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

# redirect stderr to stdout so we see ouput in webif
exec 2>&1

cgi_begin "$(lang de:"Speichern" en:"Saving")..."

echo "<p>$(lang de:"Konfiguration speichern" en:"Saving settings"):</p>"
echo -n "<pre>"

file_id=$(cgi_param id | tr -d .)

[ -e /mod/etc/reg/file.reg ] || touch /mod/etc/reg/file.reg

OIFS=$IFS
IFS='|'
set -- $(grep "^$file_id|" /mod/etc/reg/file.reg)
IFS=$OIFS

[ -r "$4" ] && . "$4"

if [ -z "$CONFIG_FILE" -o "$sec_level" -gt "$3" ]; then
	echo "Configuration file not available at the current security level!"
else
	case $CONFIG_TYPE in
		text)
			eval "$(modcgi content mod_cgi)"
			echo -n "Saving $file_id..."
			echo "$MOD_CGI_CONTENT" > "$CONFIG_FILE"
			echo 'done.'
			eval "$CONFIG_SAVE"
			;;
		list)
			eval "$CONFIG_SAVE"
			;;
	esac
fi

echo '</pre>'
echo -n "<p><form action=\"/cgi-bin/file.cgi\">"
echo -n "<input type=\"hidden\" name=\"id\" value=\"$file_id\">"
echo '<input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form></p>'

cgi_end
