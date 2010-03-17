#! /bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin

cat << EOF
<script type=text/javascript>
function CheckInput(form) {
	file_selector=form.elements[0];
	target_text=form.elements[1];
	if (file_selector.value=="") {
		alert("$(lang de:"Keine external-Datei angegeben!" en:"No external-file found!")");
		return false;
	}
	file_selector.name=target_text.value;
	return true;
}
</script>

<h1>1. $(lang de:"external-Datei hochladen" en:"upload external-file")</h1>

$(lang de:"Im ersten Schritt ist eine external-Datei zum Upload auszuw&auml;hlen. Diese Datei wird auf" en:"First choose a external-file for upload. This")
$(lang de:"die Box geladen und dort entpackt. Anschlie&szlig;end sollte die entsprechende Firmware" en:"file will be uploaded and extraced. Then you should")
$(lang de:"geflasht werden." en:"flash the expected firmware")
<p>

<form action="/cgi-bin/do_external.cgi" method=POST enctype="multipart/form-data" onsubmit="return CheckInput(document.forms[0]);">
	$(lang de:"external-Datei" en:"external-file") <input type=file size=50 id="ex_file">
	<p>
	$(lang de:"Zielverzeichnis" en:"target directory") <input type="textfield" size=50 name="the_target" value="/var/media/ftp/uStor01/external">
	<p>
	<input type=submit value="$(lang de:"Datei hochladen" en:"upload data")" style="width:150px">
</form>
<form action="/cgi-bin/status.cgi" method=GET>
	<input type="submit" value="$(lang de:"Abrechen" en:"Abort")" style="width:150px">
</form>
EOF
