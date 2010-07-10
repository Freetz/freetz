#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

file_reg=/mod/etc/reg/file.reg
[ -e "$file_reg" ] || touch "$file_reg"

path_info PACKAGE FILE_ID _
if ! valid package "$PACKAGE" || ! valid id "$FILE_ID"; then
	cgi_error "Invalid path"
	exit 2
fi

OIFS=$IFS
IFS='|'
set -- $(grep "^$PACKAGE|$FILE_ID|" "$file_reg")
IFS=$OIFS
TITLE=$3 sec=$4 def=$5

if [ $# -eq 0 ]; then
	cgi_error "$(lang
	    de:"Datei '$FILE_ID' des Pakets '$PACKAGE' ist unbekannt."
	    en:"File '$FILE_ID' of package '$PACKAGE' is unknown."
	)</p>"
	exit
fi

# Defaults
TEXT_ROWS=18

# Load config
[ -r "$def" ] && . "$def"

allowed() {
    ! [ -z "$CONFIG_FILE" -o "$sec_level" -gt "$sec" ]
}
print_access_denied() {
	echo '<div style="color: #800000;">$(lang
		de:"Konfiguration in der aktuellen Sicherheitsstufe nicht verf&uuml;gbar!"
		en:"Settings are not available at current security level!"
	)</div>'
}

case $REQUEST_METHOD in
	POST)	source file_save.sh ;;
	GET|*)	source file_edit.sh ;;
esac
