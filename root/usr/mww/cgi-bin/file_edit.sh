cgi_begin "$TITLE" "file:$PACKAGE/$FILE_ID"

echo "<h1>$CAPTION</h1>"
[ -n "$DESCRIPTION" ] && echo "<p>$DESCRIPTION</p>"

readonly=false
if ! allowed; then
	readonly=true
	print_access_denied
fi

case $CONFIG_TYPE in
	text)
		echo "<form method='post'>"
		echo -n "<div class='textwrapper'><textarea name='content' rows='$TEXT_ROWS' cols='60' wrap='off' $($readonly && echo "readonly")>"
		[ -r "$CONFIG_FILE" ] && html < "$CONFIG_FILE"
		echo '</textarea></div>'
		if ! $readonly; then
			echo '<div class="btn"><input type="submit" value="$(lang de:"&Uuml;bernehmen" en:"Apply")"></div>'
		fi
		echo '</form>'
		;;
	list)
		;;
	*)
		print_error "$(lang de:"Unbekannter Typ" en:"unknown type") '$CONFIG_TYPE'"
		;;
esac

cgi_end
