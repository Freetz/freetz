#!/usr/bin/haserl -u 10000 -U /var/tmp
<%in /usr/lib/mww/rudi_auth.cgi
%>Content-Type: text/html; charset=ISO-8859-1

<html><body>
	<script type="text/javascript"><%
	if mv "$FORM_source" "$FORM_target"
	then
		echo 'window.parent.output.innerHTML="$(lang de:"Datei erfolgreich nach '$FORM_target' hochgeladen.\\nDateigr&ouml;&szlig;e:" en:"File successfully uploaded to '$FORM_target'.\\nFile size:") '$(cat $FORM_target | wc -c)' $(lang de:"Bytes" en:"bytes")";'
	else
		echo 'window.parent.output.innerHTML="$(lang de:"FEHLER: Entweder das Hochladen oder das Umbenennen nach" en:"ERROR: Either uploading or renaming to") '$FORM_target' $(lang de:"war nicht m&ouml;glich." en:"has failed.")";'
	fi
	%></script>
</body></html>
