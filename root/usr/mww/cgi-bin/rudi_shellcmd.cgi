#!/usr/bin/haserl -u 10000 -U /var/tmp

<?
pid1=$(echo ${QUERY_STRING} | sed -n 's/.*pid=\(.*\)/\1/p' | sed -e 's/&.*//g')
pid2=$(cat /var/run/rudi_shell.pid)
if [ "$pid1" != "$pid2" ] || [ ! -f /var/run/rudi_shell.pid ]; then
	echo -n 'Content-Type: text/html; charset=ISO-8859-1'$'\r\n\r\n'
	echo -n '<html><body><script type="text/javascript">alert("$(lang de:"Sicherheitsabfrage fehlgeschlagen! Falsche PID!" en:"Security check failed! Wrong PID!")");</script></body></html>'
	exit 1
fi 
?>

<? if [ "$FORM_display_mode" = "binary" ]; then
	[ -z $FORM_download_name ] && FORM_download_name=rudi_download
	echo -n 'Content-Type: application/octet-stream'$'\r\n'
	echo -n "Content-Disposition: attachment; filename=\"$FORM_download_name"
	if [ "$FORM_tar" = "true" ]; then echo -n '.tar'; fi
	if [ "$FORM_gz" = "true" ]; then echo -n '.gz'; fi
	echo -n $'"\r\n\r\n'
	echo "$FORM_script" | sed "s/"$'\r'"//g" | sh
else
	echo -n 'Content-Type: text/html; charset=ISO-8859-1'$'\r\n\r\n'
	echo -n '<html> <body'
	if [ -n "$FORM_onload" ]; then
	 	echo -n " onLoad=\"$FORM_onload\""
	fi
	echo '>'
	echo -n '<pre id="cmd_output">'
	echo "$FORM_script" | sed "s/"$'\r'"//g" | sh | sed -e 's/&/\&amp;/g ; s/</\&lt;/g ; s/>/\&gt;/g' | head -c 64000
	echo '</pre>'
	echo '<script type="text/javascript">'
	echo '    var child = document.getElementById("cmd_output").firstChild'
	echo '    window.parent.setShellOutput(child && child.data ? child.data : "---")'
	echo '</script>'
	echo '</body></html>'
fi ?>
