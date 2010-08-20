if ! [ -r "/mod/etc/default.$PACKAGE/$PACKAGE.cfg" \
	-o -r "/mod/etc/default.$PACKAGE/$PACKAGE.save" ]; then
	cgi --id="conf:$PACKAGE"
	cgi_error "$(lang
		de:"Das Paket '$PACKAGE' ist nicht konfigurierbar."
		en:"the package '$PACKAGE' is not configurable."
	)"
	exit
fi

# retrieve metadata
CGI_REG=/mod/etc/reg/cgi.reg
[ -e "$CGI_REG" ] || touch "$CGI_REG"

if [ "$PACKAGE" = mod ]; then
	PACKAGE_TITLE='$(lang de:"Einstellungen" en:"Settings")'
else
	OIFS=$IFS; IFS="|"
	set -- $(grep "^$PACKAGE|" "$CGI_REG")
	IFS=$OIFS
	PACKAGE_TITLE=${2:-$PACKAGE}
fi

cgi --id="conf:$PACKAGE" --help="/packages/$PACKAGE"

case $REQUEST_METHOD in
	POST)   source "${HANDLER_DIR}/save.sh" ;;
	GET|*)  source "${HANDLER_DIR}/edit.sh" ;;
esac
