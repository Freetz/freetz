#!/usr/bin/haserl -u 8000000 -U /var/tmp -H /usr/mww/cgi-bin/do_update_handler.sh

<%
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
cgi_begin 'Firmware-Update'
%>

<h1>2. Firmware extrahieren, Update vorbereiten</h1>

<pre><%
cat /tmp/fw_update.log;
rm -f /tmp/fw_update.log;
%></pre>

<p>
<form action="/cgi-bin/status.cgi" method=GET>
	<input type=submit value="Zurück zur Übersicht">
</form>
<% cgi_end %>
