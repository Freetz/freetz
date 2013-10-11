#!/usr/bin/haserl -u 70000 -U /var/tmp -H /usr/lib/mww/do_update_handler.sh
<%
if [ -e /tmp/fw_update.done ]; then
	rm -f /tmp/fw_update.done
	exit
fi
%>

<%

. /usr/lib/libmodcgi.sh
cgi_error '$(lang de:"Keine Firmware hochgeladen" en:"No firmware has been uploaded")'
%>
