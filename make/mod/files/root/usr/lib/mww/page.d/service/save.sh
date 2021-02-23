. /usr/lib/cgi-bin/mod/modlibcgi

cgi --style=mod/daemons.css
SERVICE_REG=/mod/etc/reg/daemon.reg
SERVICE_PKG=/mod/etc/reg/pkg.reg
eval "$(modcgi cmd service)"

# retrieve package information
OIFS=$IFS; IFS="|"
set -- $(grep "^$ID|.*|$PACKAGE\$" "$SERVICE_REG")
IFS=$OIFS
if [ $# -gt 0 ]; then
	long="$(sed -n "s/^${3#rc.}|//p" "$SERVICE_PKG")"
	description=${long:-$2}
	rcfile=${3:+/mod/etc/init.d/$3}
fi
if [ ! -x "$rcfile" ]; then
	cgi_error "$(lang de:"Kein Skript f&uuml;r" en:"no script for") '$(html "${description:-$PACKAGE/$ID}")'"
	exit 1
fi

# redirect stderr to stdout so we see output in webif
exec 2>&1

case $SERVICE_CMD in
	start)   message="$(lang de:"Starte" en:"Starting") $description" ;;
	stop)    message="$(lang de:"Stoppe" en:"Stopping") $description" ;;
	restart) message="$(lang de:"Restarte" en:"Restarting") $description" ;;
	*)
		cgi_error "$(lang de:"Unbekannter Befehl" en:"Unknown command") '$(html "$SERVICE_CMD")'"
		exit 1
		;;
esac

cgi_begin "$message ..."
echo "<div id='result'>"
echo -n "<p>$message:</p><pre class='log.small'>"
"$rcfile" "$SERVICE_CMD" | html | highlight
echo '</pre>'
echo "</div>"

source "$HANDLER_DIR/list_body.sh"

cgi_end

