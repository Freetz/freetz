#!/usr/bin/haserl -u 20000 -U /var/tmp -H /usr/mww/cgi-bin/do_update_handler.sh

<%
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
cgi_begin '$(lang de:"Firmware-Update" en:"Firmware update")'
%>

<h1>2. $(lang de:"Firmware extrahieren, Update vorbereiten" en:"Extract firmware, prepare update")</h1>

<pre><%
cat /tmp/fw_update.log;
rm -f /tmp/fw_update.log;
%></pre>

<p>
<form action="/cgi-bin/status.cgi" method=GET>
	<input type=submit value="$(lang de:"Zurück zur Übersicht" en:"Back to main page")">
</form>
<% cgi_end %>
