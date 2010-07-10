#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
REG=/mod/etc/reg/daemon.reg

eval "$(modcgi cmd service)"
SERVICE_NAME=${PATH_INFO#/}
SERVICE_NAME=${SERVICE_NAME%%/*}

case $SERVICE_NAME in
	*/*|*..*) 
		cgi_error "Invalid service name '$(html "$SERVICE_NAME")'"
		exit 2
		;;
esac

# retrieve package information
OIFS=$IFS; IFS="|"
set -- $(grep "^$SERVICE_NAME|" "$REG")
IFS=$OIFS
if [ $# -gt 0 ]; then
	name=$2
	rcfile=${3:+/mod/etc/init.d/$3}
else
	# fallback (for base packages and AVM services)
	name=$SERVICE_NAME
	rcfile="/mod/etc/init.d/rc.$SERVICE_NAME"
fi
if [ ! -x "$rcfile" ]; then
	cgi_error "$(lang de:"Kein Skript f&uuml;r" en:"no script for") '$(html "${name:-$SERVICE_NAME}")'"
	exit 1
fi

case $SERVICE_CMD in
	start)   message="$(lang de:"Starte" en:"Starting") $name" ;;
	stop)    message="$(lang de:"Stoppe" en:"Stopping") $name" ;;
	restart) message="$(lang de:"Starte $name neu" en:"Restarting $name")" ;;
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
