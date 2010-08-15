OIFS=$IFS; IFS='|'
set -- $(grep "^$PACKAGE|.*|$ID\$" /mod/etc/reg/status.reg)
IFS=$OIFS

title=$2

# FIXME: Attach meta-data to mounted.cgi
cgi --style=mod/mounted.css --style=mod/freetz-conf.css
cgi --id="status:$PACKAGE/$ID"
cgi_begin "$title"

if [ -n "$1" -a -x "/mod/usr/lib/cgi-bin/$PACKAGE/$ID.cgi" ]; then
	. "/mod/usr/lib/cgi-bin/$PACKAGE/$ID.cgi"
else
	print_error "$(lang de:"Kein Skript f&uuml;r die Statusanzeige" en:"no script for status display") '$PACKAGE/$ID'."
fi

cgi_end
