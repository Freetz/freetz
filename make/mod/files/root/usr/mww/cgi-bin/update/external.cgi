#! /bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

external_dir="$(cat /etc/external.dir 2>/dev/null || echo /var/media/ftp/uStor01/external)"

cgi --id=firmware_update
cgi_begin '$(lang de:"external-Datei Update" en:"external-file update")'

cat << EOF
<script type=text/javascript>
function CheckInput(form) {
	file_selector=form.elements[0];
	target_text=form.elements[1];
	if (file_selector.value=="") {
		alert("$(lang de:"Keine external-Datei angegeben!" en:"No external-file provided!")");
		return false;
	}
	file_selector.name=target_text.value;
	return true;
}
</script>

<h1>$(lang de:"external-Datei hochladen" en:"Upload external-file")</h1>

<p>
$(lang de:"Im ersten Schritt ist eine external-Datei zum Upload auszuw&auml;hlen. Diese Datei wird auf" en:"First choose an external-file for upload. This")
$(lang de:"die Box geladen und dort entpackt. Anschlie&szlig;end sollte die entsprechende Firmware" en:"file will be loaded to and extracted on the Box. You should")
$(lang de:"hochgeladen werden." en:"upload the appropriate firmware afterwards.")
</p>

<form action="do_external.cgi" method=POST enctype="multipart/form-data" onsubmit="return CheckInput(document.forms[0]);">
	<p>$(lang de:"external-Datei" en:"External-file") <input type=file size=50 id="ex_file"></p>
	<p>$(lang de:"Zielverzeichnis" en:"Target directory") <input type="textfield" size=50 name="the_target" value="$external_dir"></p>
	<input type=submit value="$(lang de:"Datei hochladen" en:"Upload file")" style="width:200px">
</form>
EOF

cgi_end
