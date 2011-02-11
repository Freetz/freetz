#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/mod/sbin:/mod/bin:/mod/usr/sbin:/mod/usr/bin
. /usr/lib/libmodcgi.sh

exec 1> /tmp/fw_update.log 2>&1
indent() {
    sed 's/^/  /' | html
}

if [ "$NAME" = "stop_avm" ]; then
	echo "$(lang de:"AVM-Dienste anhalten, Teil 1" en:"Stopping AVM services, part 1") (prepare_fwupgrade start) ..."
	prepare_fwupgrade start 2>&1 | indent
	echo "$(lang de:"ERLEDIGT" en:"DONE")"
	echo "</pre><pre>"
fi

echo "$(lang de:"Firmware-Archiv extrahieren" en:"Extracting firmware archive") ..."
tar_log="$(cat "$1" | tar -C / -xv 2>&1)"
result=$?
echo "$tar_log" | indent
if [ $result -ne 0 ]; then
	echo "$(lang de:"FEHLGESCHLAGEN" en:"FAILED")"
	exit 1
fi
echo "DONE"

if [ "$NAME" = "stop_avm" ]; then
	echo "</pre><pre>"
	echo "$(lang de:"AVM-Dienste anhalten, Teil 2" en:"Stopping AVM services, part 2") (prepare_fwupgrade end) ..."
	prepare_fwupgrade end 2>&1 | indent
	echo "$(lang de:"ERLEDIGT" en:"DONE")"
fi

echo "</pre><pre>"
echo "$(lang de:"Ausführen des Firmware-Installationsskripts" en:"Executing firmware installation script") /var/install ..."
if [ ! -x /var/install ]; then
	echo "$(lang de:"FEHLGESCHLAGEN - Installationsskript nicht gefunden oder nicht ausführbar." en:"FAILED - installation script not found or not executable.")"
	echo
	echo "$(lang de:"Weiter ohne Neustart." en:"Resuming without reboot.")"
	echo "$(lang de:"Sie sollten bei Bedarf noch die extrahierten Dateien löschen." en:"You may want to clean up the extracted files.")"
	exit 1
fi
# Remove no-op original from var.tar
rm -f /var/post_install
inst_log="$(/var/install 2>&1)"
result=$?
echo "$inst_log" | indent
unset inst_log
case $result in
	0) result_txt="INSTALL_SUCCESS_NO_REBOOT" ;;
	1) result_txt="INSTALL_SUCCESS_REBOOT" ;;
	2) result_txt="INSTALL_WRONG_HARDWARE" ;;
	3) result_txt="INSTALL_KERNEL_CHECKSUM" ;;
	4) result_txt="INSTALL_FILESYSTEM_CHECKSUM" ;;
	5) result_txt="INSTALL_URLADER_CHECKSUM" ;;
	6) result_txt="INSTALL_OTHER_ERROR" ;;
	7) result_txt="INSTALL_FIRMWARE_VERSION" ;;
	8) result_txt="INSTALL_DOWNGRADE_NEEDED" ;;
	*) result_txt="$(lang de:"unbekannter Fehlercode" en:"unknown error code")" ;;
esac
echo "$(lang de:"ERLEDIGT - Rückgabewert des Installationsskripts" en:"DONE - installation script return code") = $result ($result_txt)"

echo "</pre><pre>"
echo "$(lang de:"Von" en:"Generated content of") /var/post_install$(lang de:" generierter Inhalt:" en:":")"
if [ ! -x /var/post_install ]; then
	echo "$(lang de:"KEINER - Nach-Installationsskript nicht gefunden oder nicht ausführbar." en:"NONE - post-installation script not found or not executable.")"
	exit 1
fi
cat /var/post_install | indent
echo "$(lang de:"ENDE DER DATEI" en:"END OF FILE")"
echo
echo "$(lang de:"Das Nach-Installationsskript läuft beim Neutart (reboot) und führt die" en:"The post-installation script will be executed upon reboot and perform")"
echo "$(lang de:"darin definiterten Aktionen aus, z.B. das tatsächliche Flashen der Firmware." en:"the actions specified therein, e.g. the actual firmware flashing.")"
echo "$(lang de:"Sie können immer noch entscheiden, diesen Vorgang abzubrechen, indem Sie" en:"You may still choose to interrupt this process by removing the script")"
echo "$(lang de:"das Skript und den Rest der extrahierten Firmware-Komponenten löschen." en:"along with the rest of the extracted firmware components.")"
