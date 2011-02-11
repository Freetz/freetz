#!/usr/bin/haserl -u 100000 -U /var/tmp -H /usr/mww/cgi-bin/do_external_handler.sh

<%
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
cgi_begin '$(lang de:"external-Update" en:"external-update")'
%>

<h1>2. $(lang de:"Dateien extrahieren" en:"Extract files")</h1>

<pre><%
cat /tmp/ex_update.log;
rm -f /tmp/ex_update.log;
%></pre>

<p>
<form action="/cgi-bin/status.cgi" method=GET>
	<input type=submit value="$(lang de:"Zurück zur Übersicht" en:"Back to main page")">
</form>
<% cgi_end %>
