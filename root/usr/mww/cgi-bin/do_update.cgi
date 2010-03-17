#!/usr/bin/haserl -u 20000 -U /var/tmp -H /usr/lib/mww/do_update_handler.sh

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
<% back_button /cgi-bin/status.cgi "$(lang de:"Zurück zur Übersicht" en:"Back to main page")" %>
<% cgi_end %>
