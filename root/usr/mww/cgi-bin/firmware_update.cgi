#! /bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi_begin '$(lang de:"Firmware-Update" en:"Firmware update")' firmware_update

cat << EOF
<script type="text/javascript">
function CheckInput(form) {
	file_selector=form.elements[0];
	radio_stop=form.elements[1];
	radio_semistop=form.elements[2];
	radio_nostop=form.elements[3];
	downgrade=form.elements[4];
	
	if (file_selector.value=="") {
		alert("$(lang de:"Keine Firmware-Datei angegeben!" en:"No firmware file selected!")");
		return false;
	}
	if (radio_stop.checked) {
		file_selector.name="stop_avm";
	}
	else if (radio_semistop.checked) {
		file_selector.name="semistop_avm";
	}
	else {
		file_selector.name="nostop_avm";
	}
	if (downgrade.checked) {
	    	file_selector.name += "/downgrade";
	}

	return true;
}
</script>

<h1>1. $(lang de:"Firmware hochladen" en:"Upload firmware")</h1>

<p>$(lang 
    de:"Im ersten Schritt ist ein Firmware-Image zum Upload auszuw&auml;hlen.
Dieses Image wird auf die Box geladen und dort entpackt. Anschlie&szlig;end
wird <i>/var/install</i> aufgerufen. Falls das erfolgreich ist, kann das Update
mit einem Klick auf den Neustart-Button ausgef&uuml;hrt werden. Bei Auswahl des
Men&uuml;punkts f&uuml;r Remote-Update wird die Box nach 30 Sekunden automatisch neu
gestartet."
    en:"In step 1 you are to select a firmware image for upload. This image
will be uploaded to and unpacked on the box. Subsequently, <i>/var/install</i>
will be called. If successful, the update can be started by clicking the reboot
button. If remote update is selected, the box restarts automatically after 30
seconds."
)</p>

<form action="/cgi-bin/do_update.cgi" method="POST" enctype="multipart/form-data" onsubmit="return CheckInput(document.forms[0]);">
	<p>
	$(lang de:"Firmware-Image" en:"Firmware image")
	<input type=file size=50 id="fw_file">
	</p><p>
	$(lang de:"AVM-Dienste ..." en:"")<br>
	<input type="radio" name="do_prepare" value="stop_avm">
	$(lang de:"stoppen (bei Speichermangel)" en:"Stop AVM services (low available memory)")<br>
	<input type="radio" name="do_prepare" value="semistop_avm">
	$(lang de:"teilweise stoppen (bei Remote-Update)" en:"Stop AVM services partially (remote firmware update)")<br>
	<input type="radio" name="do_prepare" value="nostop_avm" checked>
	$(lang de:"nicht stoppen (bei genug Speicher bzw. Pseudo-Update ohne Reboot)" en:"Do not stop AVM services (enough available memory or pseudo update without reboot)")
	</p>
	<p>
	<input type="checkbox" name="downgrade" value="yes">
	$(lang de:"Downgrade auf niedrigere Version zulassen" en:"Allow downgrade to lower version")
	</p>
	<div class="btn"><input type=submit value="$(lang de:"Firmware hochladen" en:"Upload firmware")" style="width:150px"></div>
</form>
<br style="clear: both;">
<br>

<form class="btn" action="/cgi-bin/external_update.cgi" method="GET">
	<input type="submit" value="external (optional)" style="width:150px">
</form>

EOF

cgi_end
