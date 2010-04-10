#!/usr/bin/haserl -u 100000 -U /var/tmp -H /usr/lib/mww/do_external_handler.sh

<%
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
cgi_begin '$(lang de:"external-Update" en:"external-update")'
%>

<h1>2. $(lang de:"Dateien extrahieren" en:"Extract files")</h1>

<pre><%
cat /tmp/ex_update.log
rm -f /tmp/ex_update.log
%></pre>

<p>
<% back_button /cgi-bin/status.cgi "$(lang de:"Zurück zur Übersicht" en:"Back to main page")" %>
<% cgi_end %>
