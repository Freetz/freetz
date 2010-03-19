#!/usr/bin/haserl -u 10000 -U /var/tmp
<%in /usr/lib/mww/rudi_auth.cgi 
%>Content-Type: text/html; charset=ISO-8859-1

<html><body>
	<pre id="cmd_output"><% if mv "$FORM_source" "$FORM_target"
		then
			echo "$(lang de:"Datei erfolgreich nach $FORM_target hochgeladen." en:"File successfully uploaded to $FORM_target.")"
			echo "$(lang de:"Dateigröße:" en:"File size:") $(cat ""$FORM_target"" | wc -c) $(lang de:"Bytes" en:"bytes")"
		else
			echo
			echo "$(lang de:"FEHLER: Entweder das Hochladen oder das Umbenennen nach" en:"ERROR: Either uploading or renaming to")"
			echo "$FORM_target $(lang de:"war nicht möglich." en:"has failed.")"
		fi %>
	</pre>
	<script type="text/javascript">
		window.parent.setShellOutput(document.getElementById("cmd_output").firstChild.data)
	</script>
</body></html>
