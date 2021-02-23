file_reg=/mod/etc/reg/file.reg
[ -e "$file_reg" ] || touch "$file_reg"

OIFS=$IFS
IFS='|'
set -- $(grep "^$PACKAGE|$ID|" "$file_reg")
IFS=$OIFS
TITLE=$3 sec=$4 def=$5

if [ $# -eq 0 ]; then
	cgi_error "$(lang \
	  de:"Datei '$ID' des Pakets '$PACKAGE' ist unbekannt." \
	  en:"File '$ID' of package '$PACKAGE' is unknown." \
	)</p>"
	exit
fi

# Defaults
TEXT_ROWS=35
CONFIG_PREPARE=
HELP=

# Load config
[ -r "$def" ] && . "$def"

allowed() {
	! [ -z "$CONFIG_CMD$CONFIG_FILE" -o "$sec_level" -gt "$sec" ]
}
print_access_denied() {
	print_warning "$(lang \
	  de:"Konfiguration in der aktuellen Sicherheitsstufe nicht verf&uuml;gbar!" \
	  en:"Settings are not available at current security level!" \
	)"
}

readonly=false
if ! allowed || [ "$CONFIG_SAVE" == "false" ]; then
    readonly=true
fi

cgi --id="file:$PACKAGE/$ID" --help="${HELP:-/packages/$PACKAGE#$ID}"

case $REQUEST_METHOD in
	POST)	source "$HANDLER_DIR/save.sh" ;;
	GET|*)	source "$HANDLER_DIR/edit.sh" ;;
esac

