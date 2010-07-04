cgi_begin "$(lang de:"Speichern" en:"Saving")..."

echo "<p>$(lang de:"Konfiguration speichern" en:"Saving settings"):</p>"

if ! allowed; then
    	print_access_denied
else
	echo -n "<pre>"

	# redirect stderr to stdout so we see output in webif
	exec 2>&1

	case $CONFIG_TYPE in
		text)
			eval "$(modcgi content mod_cgi)"
			echo -n "Saving $PACKAGE/$FILE_ID..."
			echo "$MOD_CGI_CONTENT" > "$CONFIG_FILE"
			echo 'done.'
			eval "$CONFIG_SAVE"
			;;
		list)
			eval "$CONFIG_SAVE"
			;;
	esac
	echo '</pre>'
fi

back_button file "$PACKAGE" "$FILE_ID"

cgi_end
