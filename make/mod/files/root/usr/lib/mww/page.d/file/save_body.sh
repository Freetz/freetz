. /usr/lib/cgi-bin/mod/modlibcgi
echo "<p>$(lang de:"Konfiguration speichern" en:"Saving settings"):</p>"

if ! allowed; then
	print_access_denied
else
	echo -n "<pre class='log.small'>"

	# redirect stderr to stdout so we see output in webif
	exec 2>&1

	case $CONFIG_TYPE in
		text)
			eval "$(modcgi content mod_cgi)"
			echo -n "Saving $PACKAGE/$ID ... "
			echo "$MOD_CGI_CONTENT" > "$CONFIG_FILE"
			echo 'done.'
			eval "$CONFIG_SAVE"
			;;
		list)
			eval "$CONFIG_SAVE"
			;;
	esac
	echo '</pre>'
fi | while read line; do echo $line | highlight; done

