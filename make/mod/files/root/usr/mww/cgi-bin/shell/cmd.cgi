#!/usr/bin/haserl -u 10000 -U /var/tmp
<%in /usr/lib/mww/rudi_auth.cgi %><%#

%><% if [ "$FORM_dl" = "true" ]; then
	[ -z $FORM_download_name ] && FORM_download_name=rudi_download
	echo -n 'Content-Type: application/octet-stream'$'\r\n'
	echo -n "Content-Disposition: attachment; filename=\"$FORM_download_name"
	if [ "$FORM_tar" = "true" ]; then echo -n '.tar'; fi
	if [ "$FORM_gz" = "true" ]; then echo -n '.gz'; fi
	echo -n $'"\r\n\r\n'
	echo "$FORM_script" | sed "s/"$'\r'"//g" | sh
else
	echo -n 'Content-Type: text/html'$'\r\n\r\n'
	echo "$FORM_script" | sed "s/"$'\r'"//g" | sh | sed -e 's/&/\&amp;/g ; s/</\&lt;/g ; s/>/\&gt;/g' | head -c 64000
fi %>
