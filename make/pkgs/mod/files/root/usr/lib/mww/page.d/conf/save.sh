cgi_begin "$PACKAGE_TITLE: $(lang de:"Speichern" en:"Saving") ..."

echo "<div id='result'>"
( source "$HANDLER_DIR/save_body.sh" )
echo "</div>"
( source "$HANDLER_DIR/edit_body.sh" )

cgi_end

