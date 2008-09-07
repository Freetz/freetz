#! /bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin

cat << EOF
<script type=text/javascript>
function CheckInput(form) {
	file_selector=form.elements[0];
	radio_stop=form.elements[1];
	if (file_selector.value=="") {
		alert("$(lang de:"Keine Firmware-Datei angegeben!" en:"No firmware file selected!")");
		return false;
	}
	file_selector.name=radio_stop.checked ? "stop_avm" : "nostop_avm";
	return true;
}
</script>

<h1>1. $(lang de:"Firmware hochladen" en:"Upload firmware")</h1>

$(lang de:"Im ersten Schritt ist ein Firmware-Image zum Upload auszuw&auml;hlen. Dieses Image wird auf" en:"In step 1 you are to select a firmware image for upload. This image will be uploaded to and")
$(lang de:"die Box geladen und dort entpackt. Anschlie&szlig;end wird <i>/var/install</i> aufgerufen. Falls das" en:"unpacked on the box. Subsequently, <i>/var/install</i> will be called. If successful, the update")
$(lang de:"erfolgreich ist, kann das Update mit einem Klick auf den Neustart-Button (siehe Übersichts-Seite)" en:"can be started by clicking the reboot button (see main page).")
$(lang de:"ausgef&uuml;hrt werden." en:"")
<p>

<form action="/cgi-bin/do_update.cgi" method=POST enctype="multipart/form-data" onsubmit="return CheckInput(document.forms[0]);">
	$(lang de:"Firmware-Image" en:"Firmware image") <input type=file size=50 id="fw_file">
	<p>
	<input type="radio" name="do_prepare" value="stop_avm" checked>
	$(lang de:"AVM-Dienste stoppen (bei Speichermangel)" en:"Stop AVM services (low available memory)")<br>
	<input type="radio" name="do_prepare" value="nostop_avm">
	$(lang de:"AVM-Dienste nicht stoppen (bei genug Speicher bzw. Pseudo-Update ohne Reboot)" en:"Do not stop AVM services (enough available memory or pseudo update without reboot)")
	<p>
	<input type=submit value="$(lang de:"Firmware hochladen" en:"Upload firmware")" style="width:150px">
</form>
<form action="/cgi-bin/status.cgi" method=GET>
	<input type="submit" value="$(lang de:"Abbrechen" en:"Cancel")" style="width:150px">
</form>

<br>
<br>

<form class="btn" action="/cgi-bin/exec.cgi" method="post">
	<input type="hidden" name="cmd" value="external_update">
	<input type="submit" value="external (optional)" style="width:150px">
</form>

EOF
