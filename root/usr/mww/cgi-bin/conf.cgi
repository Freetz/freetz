#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
source /usr/lib/libmodcgi.sh

path_info PACKAGE _
if ! valid package "$PACKAGE"; then
	cgi_error "$PACKAGE: $(lang de:"Unbekanntes Paket" en:"Unknown package")"
	exit
fi

if ! [ -r "/mod/etc/default.$PACKAGE/$PACKAGE.cfg" \
	-o -r "/mod/etc/default.$PACKAGE/$PACKAGE.save" ]; then
	cgi_error "$(lang
		de:"Das Paket '$PACKAGE' ist nicht konfigurierbar."
		en:"the package '$PACKAGE' is not configurable."
	)" "pkg:$PACKAGE"
	exit
fi

# retrieve metadata
CGI_REG=/mod/etc/reg/cgi.reg
[ -e "$CGI_REG" ] || touch "$CGI_REG"

if [ "$PACKAGE" = mod ]; then
    	PACKAGE_TITLE='$(lang de:"Einstellungen" en:"Settings")'
	MENU_ID=settings
else
	OIFS=$IFS; IFS="|"
	set -- $(grep "^$PACKAGE|" "$CGI_REG")
	IFS=$OIFS
	PACKAGE_TITLE=${2:-$PACKAGE}
	MENU_ID="pkg:$PACKAGE"
fi

case $REQUEST_METHOD in
	POST)   source conf_save.sh ;;
	GET|*)  source conf_edit.sh ;;
esac
