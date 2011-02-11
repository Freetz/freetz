#!/usr/bin/haserl -u 10000 -U /var/tmp
Content-Type: text/html; charset=ISO-8859-1

<?
pid1=`echo ${QUERY_STRING} | sed -n 's/.*pid=\(.*\)/\1/p' | sed -e 's/&.*//g'`
pid2=`cat /var/run/rudi_shell.pid`
if [ "$pid1" != "$pid2" ] || [ ! -f /var/run/rudi_shell.pid ]; then
	echo -n '<html><body>$(lang de:"Sicherheitsabfrage fehlgeschlagen! Falsche PID!" en:"Security check failed! Wrong PID!")</body></html>'
	exit 1
fi
?>

<html><body>
	<pre id="cmd_output"><? if mv "$FORM_source" "$FORM_target"
		then
			echo "$(lang de:"Datei erfolgreich nach $FORM_target hochgeladen." en:"File successfully uploaded to $FORM_target.")"
			echo "$(lang de:"Dateigröße:" en:"File size:") $(cat ""$FORM_target"" | wc -c) $(lang de:"Bytes" en:"bytes")"
		else
			echo
			echo "$(lang de:"FEHLER: Entweder das Hochladen oder das Umbenennen nach" en:"ERROR: Either uploading or renaming to")"
			echo "$FORM_target $(lang de:"war nicht möglich." en:"has failed.")"
		fi ?>
	</pre>
	<script type="text/javascript">
		window.parent.setShellOutput(document.getElementById("cmd_output").firstChild.data)
	</script>
</body></html>
