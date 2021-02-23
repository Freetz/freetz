cgi --id=daemons
cgi --style=mod/daemons.css
cgi_begin "$(lang de:"Dienste" en:"Services")"

source "$HANDLER_DIR/list_body.sh"

cgi_end
