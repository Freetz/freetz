#!/usr/bin/haserl -u 10000 -U /var/tmp

<?
if $(echo "$QUERY_STRING" | grep -q dosave) ; then
	echo 'Content-Type: application/octet-stream'
	echo 'Content-Disposition: attachment; filename="AVM_FWD_rules.txt"'
	echo
	httpd -d "$(echo "$QUERY_STRING" | sed 's/^.*dosave\&//' )"
	echo
	exit
fi

if $(echo "$QUERY_STRING" | grep -q doload) ; then
	echo -e 'Content-Type: text/html; charset=ISO-8859-1\n'
	echo '<html><body>'
	echo '<textarea id="txt" style="width: 0px;">'
	cat "$FORM_source"
	echo '</textarea>'
	echo '<script> '
	echo 'parent.document.getElementById("forwardingrules").value = document.getElementById("txt").value'
	echo 'parent.FWD_textarea_to_rules()'
	echo 'location.href="/cgi-bin/avm_fw_helper.cgi"'
	echo '</script>'
	echo '</body></html>'
	exit
fi

cat << EOF 
Content-Type: text/html; charset=ISO-8859-1

<html><body>
<form id="id_form" enctype="multipart/form-data" method="post" action="avm_fw_helper.cgi?doload" > 
<input type="button" value="Export Forwardings" onclick='location.href="/cgi-bin/avm_fw_helper.cgi?dosave&"+escape(parent.document.getElementById("forwardingrules").value);'>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
<input type="file" name="source" id="text_source"> 
<input type=submit value="Import Forwardings">
</form>
</body></html>
EOF

?>
