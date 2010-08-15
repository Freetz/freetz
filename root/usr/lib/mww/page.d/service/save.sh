REG=/mod/etc/reg/daemon.reg
eval "$(modcgi cmd service)"

# retrieve package information
if [ "$PACKAGE" = mod ]; then
	# fallback (for base packages and AVM services)
	description=$ID
	rcfile="/mod/etc/init.d/rc.$ID"
else
	OIFS=$IFS; IFS="|"
	set -- $(grep "^$ID|.*|$PACKAGE\$" "$REG")
	IFS=$OIFS
	if [ $# -gt 0 ]; then
		description=$2
		rcfile=${3:+/mod/etc/init.d/$3}
	fi
fi
if [ ! -x "$rcfile" ]; then
	cgi_error "$(lang de:"Kein Skript f&uuml;r" en:"no script for") '$(html "${description:-$PACKAGE/$ID}")'"
	exit 1
fi

case $SERVICE_CMD in
	start)   message="$(lang de:"Starte" en:"Starting") $description" ;;
	stop)    message="$(lang de:"Stoppe" en:"Stopping") $description" ;;
	restart) message="$(lang de:"Starte $description neu" en:"Restarting $description")" ;;
	*)
		cgi_error "$(lang de:"Unbekannter Befehl" en:"Unknown command") '$(html "$SERVICE_CMD")'"
		exit 1
		;;
esac

cgi_begin "$message ..."
echo -n "<p>$message:</p><pre>"
"$rcfile" "$SERVICE_CMD" | html
echo '</pre>'
back_button mod daemons
cgi_end
