#!/usr/bin/haserl -u 200 -U /var/tmp
<%

. /usr/lib/libmodcgi.sh
cgi --id=do_restore
cgi_begin "$(lang de:"Konfiguration wiederherstellen (Restore)" en:"Restore configuration")"
echo "<h1>$(lang de:"Wiederherstellung (Restore)" en:"Restore configuration")</h1>"

if [ -n "$FORM_uploadfile_name" ]; then
	echo "<p>"
	echo "$(lang de:"Sie haben gerade die Datei" en:"You just uploaded the file") <b>$FORM_uploadfile_name</b>$(lang de:" hochgeladen." en:".")<br>"
	echo "$(lang de:"Sie ist unter dem tempor&auml;ren Namen" en:"It is stored on the device under the temporary name") <i>$FORM_uploadfile</i>$(lang de:" auf dem Ger&auml;t gespeichert." en:".")<br>"
	echo "$(lang de:"Die Dateigr&ouml;&szlig;e betr&auml;gt" en:"The file size is") $(cat $FORM_uploadfile | wc -c) $(lang de:"Bytes." en:"bytes.")"
	echo "</p>"
	echo "<b>$(lang de:"Installationsverlauf:" en:"Installation log:")</b>"
	echo "<pre>"
	{
		cd /var/tmp
		export BACKUP_DIR='var_flash'
		export FREETZ_BCK_FILE='freetz'
		rm -rf $BACKUP_DIR
		echo "$(lang de:"Sicherungsdateien extrahieren" en:"Extracting backup files") ... "
		tar xvzf $FORM_uploadfile
		echo "$(lang de:"Konfiguration wiederherstellen" en:"Restoring configuration") ... "
		if [ ! -e "$BACKUP_DIR/$FREETZ_BCK_FILE" ]; then
			FORM_restart=off
			echo "$(lang de:"FEHLER: Keine passende Sicherungsdatei" en:"ERROR: Not a valid backup file")"
		else
			if [ "$FORM_freetz_only" = "on" ]; then
				echo "cat $BACKUP_DIR/$FREETZ_BCK_FILE > /var/flash/freetz"
				cat $BACKUP_DIR/$FREETZ_BCK_FILE > /var/flash/freetz
			else
				for file in $(ls $BACKUP_DIR); do
					echo "cat $BACKUP_DIR/$file > /var/flash/$file"
					cat $BACKUP_DIR/$file > /var/flash/$file
				done
			fi
			echo "$(lang de:"ERLEDIGT" en:"DONE")"
		fi
	echo "$(lang de:"Sicherungsdateien entfernen" en:"Removing backup") ... "
	rm -rf $BACKUP_DIR
	rm -f $FORM_uploadfile
	echo "$(lang de:"ERLEDIGT" en:"DONE")"
	if [ "$FORM_restart" = "on" ]; then
		echo "$(lang de:"Neustart" en:"Restarting") ... "
		touch /tmp/.do_restore.restart
	fi
	} | html
	echo "</pre>"
else
	echo "$(lang de:"Sie haben keine Sicherungs-Datei zum Hochladen ausgew&auml;hlt. Der Zustand" en:"You have not selected any backup file to upload. The device's")"
	echo "$(lang de:"des Ger&auml;tes wurde nicht ver&auml;ndert." en:"configuration was not changed.")"
fi

echo "<p>"
back_button --title="$(lang de:"Zur&uuml;ck zur &Uuml;bersicht" en:"Back to main page")" mod status
echo "</p>"

cgi_end

[ -e /tmp/.do_restore.restart ] && reboot

%>

