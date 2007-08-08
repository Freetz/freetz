#! /bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin

cat << EOF
<script type=text/javascript>
function CheckInput(form) {
	file_selector=form.elements[0];
	radio_stop=form.elements[1];
	if (file_selector.value=="") {
		alert("Keine Firmware-Datei angegeben!");
		return false;
	}
	file_selector.name=radio_stop.checked ? "stop_avm" : "nostop_avm";
	return true;
}
</script>

<h1>1. Firmware hochladen</h1>
Im ersten Schritt ist ein Firmware-Image zum Upload auszuw&auml;hlen. Dieses Image wird auf 
die Box geladen und dort entpackt. Anschlie&szlig;end wird <i>/var/install</i> aufgerufen. Falls das 
erfolgreich ist, kann das Update mit einem Klick auf den Reboot-Button ausgef&uuml;hrt werden.
<p>
<form action="/cgi-bin/do_update.cgi" method=POST enctype="multipart/form-data" onsubmit="return CheckInput(document.forms[0]);">
	Firmware-Image <input type=file size=50 id="fw_file">
	<p>
	<input type="radio" name="do_prepare" value="stop_avm" checked>
	AVM-Dienste stoppen (bei Speichermangel)<br>
	<input type="radio" name="do_prepare" value="nostop_avm">
	AVM-Dienste nicht stoppen (bei genug Speicher bzw. Pseudo-Update ohne Reboot)
	<p>
	<input type=submit value="Firmware hochladen" style="width:150px">
</form>
<form action="/cgi-bin/status.cgi" method=GET>
	<input type="submit" value="Abbrechen" style="width:150px">
</form>
EOF
