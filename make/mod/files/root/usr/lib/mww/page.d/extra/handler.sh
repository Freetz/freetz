EXTRA_REG=/mod/etc/reg/extra.reg
[ -e "$EXTRA_REG" ] || touch "$EXTRA_REG"

IFS='|'
set -- $(grep "^$PACKAGE|.*|$ID\$" "$EXTRA_REG")
IFS=$OIFS
sec=${3:-2}

cgi --id="extra:$PACKAGE/$ID" --help="/packages/$PACKAGE#$ID"

if [ "$sec_level" -gt "$sec" ]; then
	cgi_begin 'Extras'
	echo "<h1>$(lang de:"Zusatz-Skript" en:"Additional script")</h1>"
	print_warning "$(lang \
	  de:"Dieses Zusatz-Skript ist in der aktuellen Sicherheitsstufe nicht verf&uuml;gbar!" \
	  en:"This script is not available at the current security level!" \
		)"
	back_button --title="$(lang de:"Zu den Extras" en:"Goto extras")" mod extras
	cgi_end
	exit
fi

path="$PACKAGE/$ID"
script="/mod/usr/lib/cgi-bin/$path.cgi"
if [ -x "$script" ]; then
	"$script"
else
	cgi_error "$(lang \
	  de:"Zusatz-Skript '$path.cgi' nicht gefunden." \
	  en:"Additional script '$path.cgi' not found." \
	)"
fi

