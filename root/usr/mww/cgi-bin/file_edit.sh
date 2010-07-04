cgi_begin "$TITLE" "file:$PACKAGE/$FILE_ID"

# Defaults
TEXT_ROWS=18

# Set width
let _width=_cgi_width-230

echo "<h1>$CAPTION</h1>"
[ -n "$DESCRIPTION" ] && echo "<p>$DESCRIPTION</p>"

readonly=false
if ! allowed; then
	readonly=true
	print_access_denied
fi

case $CONFIG_TYPE in
	text)
		echo "<form action='/cgi-bin/file.cgi?pkg=$PACKAGE&amp;id=$FILE_ID' method='post'>"
		echo -n "<textarea style='width: ${_width}px;' name='content' rows='$TEXT_ROWS' cols='60' wrap='off' $($readonly && echo "readonly")>"
		[ -r "$CONFIG_FILE" ] && html < "$CONFIG_FILE"
		echo '</textarea>'
		if ! $readonly; then
			echo '<div class="btn"><input type="submit" value="$(lang de:"&Uuml;bernehmen" en:"Apply")"></div>'
		fi
		echo '</form>'
		;;
	list)
		;;
	*)
		echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Unbekannter Typ" en:"unknown type") '$CONFIG_TYPE'</p>"
		;;
esac

cgi_end
