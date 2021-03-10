#!/usr/bin/haserl -u 200 -U /var/tmp
<%

. /usr/lib/libmodcgi.sh
cgi --id=do_restore
cgi_begin "$(lang de:"Konfiguration wiederherstellen (Restore)" en:"Restore configuration")"
echo "<h1>$(lang de:"Wiederherstellung (Restore)" en:"Restore configuration")</h1>"

export SICPW="$FORM_password_restore"
[ "$FORM_freetz_only" == "on" ] && FONLY='var_flash/freetz' || FONLY=''
OUTER_DIR="/tmp/settings.tmp.restore"
INNER_DIR="$OUTER_DIR/var_flash"
rm  -rf  "$OUTER_DIR"
mkdir -p "$OUTER_DIR"

FAILURE="n"
fail() {
	[ -n "$1" ] && echo "$@"
	FAILURE='y'
}
okay() {
	[ "$FAILURE" != "y" ] && echo -e "$(lang de:"ERLEDIGT" en:"DONE")\n" || echo
}

if [ -z "$FORM_uploadfile_name" ]; then
	fail
	echo "$(lang de:"Sie haben keine Sicherungsdatei zum Hochladen ausgew&auml;hlt. Der Zustand" en:"You have not selected any backup file to upload. The device's")"
	echo "$(lang de:"des Ger&auml;tes wurde nicht ver&auml;ndert." en:"configuration was not changed.")"

else
	echo "<p>"
	echo "$(lang de:"Sie haben gerade die Datei" en:"You just uploaded the file") <b>$FORM_uploadfile_name</b>$(lang de:" hochgeladen." en:".")<br>"
	echo "$(lang de:"Sie ist unter dem tempor&auml;ren Namen" en:"It is stored on the device under the temporary name") <i>$FORM_uploadfile</i>$(lang de:" auf dem Ger&auml;t gespeichert." en:".")<br>"
	echo "$(lang de:"Die Dateigr&ouml;&szlig;e betr&auml;gt" en:"The file size is") $(cat $FORM_uploadfile | wc -c) $(lang de:"Bytes." en:"bytes.")"
	echo "</p>"
fi

echo "<b>$(lang de:"Installationsverlauf:" en:"Installation log:")</b>"
echo "<pre>"

# unpack
if [ "$FAILURE" != "y" -a -e "$FORM_uploadfile" ]; then
	echo "$(lang de:"Entpacke hochgeladene Datei" en:"Extracting uploaded file") ..."
	[ "${FORM_uploadfile%.tgz}" != "$FORM_uploadfile" ] && COMPR='z' || COMPR=''
	tar xv${COMPR}f "$FORM_uploadfile" -C "$OUTER_DIR" --exclude=contents.txt --exclude=environment.txt.crypted \
	  || fail "$(lang de:"FEHLER: Die Datei konnte nicht entpackt werden" en:"ERROR: The file could not be unpacked")."
	okay
fi

# identity
if [ "$FAILURE" != "y" -a -e "$OUTER_DIR/identity.md5" -a "$FORM_freetz_only" != "on" ]; then
	echo "$(lang de:"Pr&uuml;fe Identit&auml;t" en:"Checking identity") ..."
	IDENT_r="$(cat "$OUTER_DIR/identity.md5")"
	IDENT_l="$(sort /proc/sys/urlader/environment | sed -rn "s/^(SerialNumber|maca|tr069_passphrase|wlan_key)[ \t]*//p" | md5sum | sed 's/ .*//')"
	echo "$(lang de:"Aktuelles Ger&auml;t" en:"This device"): $IDENT_l"
	echo "$(lang de:"Sicherungsdatei" en:"Backup file"): $IDENT_r"
	[ "$IDENT_l" != "$IDENT_r" ] \
	  && fail "$(lang de:"FEHLER: Diese Sicherungsdatei wurde auf einem anderen Ger&auml;t erstellt" en:"ERROR: This backup file was created on another device")."
	rm -f "$OUTER_DIR/identity.md5"
	okay
fi

# password
if [ "$FAILURE" != "y" -a -e "$OUTER_DIR/settings.tgz.crypted" -a -z "$SICPW" ]; then
	echo "$(lang de:"Verschl&uuml;sselte Sicherungsdatei erkannt" en:"Detected encrypted backup file") ..."
	[ -x "$(which openssl)" ] \
	  && fail "$(lang de:"FEHLER: Es wurde kein Passwort angegeben" en:"ERROR: No password was supplied")." \
	  || fail "$(lang de:"FEHLER: OpenSSL ist nicht installiert" en:"ERROR: OpenSSL is not installed")."
	okay
fi

# openssl
if [ "$FAILURE" != "y" ] && [ -e "$OUTER_DIR/settings.tgz.crypted" ]; then
	SSLV="$(openssl version | sed -rn 's/^OpenSSL ([0-9])\.([0-9])\..*/\1\2/p')"
	[ "$SSLV" -lt 11 2>/dev/null ] && F1ST='-md sha256' && S2ND='-pbkdf2'
	[ "$SSLV" -ge 11 2>/dev/null ] && S2ND='-md sha256' && F1ST='-pbkdf2'
fi

# crypted
if [ "$FAILURE" != "y" -a -e "$OUTER_DIR/settings.tgz.crypted" ]; then
	echo "$(lang de:"Sicherungsdateien entschl&uuml;sseln" en:"Decrypting backup files") ..."
	openssl         enc -d -aes256 $F1ST -in "$OUTER_DIR/settings.tgz.crypted" -pass env:SICPW | tar xvz -C "$OUTER_DIR" $FONLY
	retval=$?
	if [ "$retval" != "0" ]; then
		echo "$(lang de:"Pr&uuml;fe OpenSSL 1.0 Kompatibilit&auml;tsmodus" en:"Trying OpenSSL 1.0 compatibility mode") ..."
		openssl enc -d -aes256 $S2ND -in "$OUTER_DIR/settings.tgz.crypted" -pass env:SICPW | tar xvz -C "$OUTER_DIR" $FONLY
		retval=$?
	fi
	[ "$retval" != "0" ] && fail "$(lang de:"FEHLER: Datei kann nicht entschl&uuml;sselt werden" en:"ERROR: File could not be dectypted")."
	rm -f "$OUTER_DIR/settings.tgz.crypted"
	okay
fi

# plain
if [ "$FAILURE" != "y" -a -e "$OUTER_DIR/settings.tgz" ]; then
	echo "$(lang de:"Sicherungsdateien extrahieren" en:"Extracting backup files") ..."
	cat                                "$OUTER_DIR/settings.tgz"                         | tar xvz -C "$OUTER_DIR" $FONLY \
	  || fail "$(lang de:"FEHLER: Die Daten konnte nicht entpackt werden" en:"ERROR: The data could not be unpacked")."
	rm -f "$OUTER_DIR/settings.tgz"
	okay
fi

# validity
[ "$FAILURE" != "y" -a ! -e "$INNER_DIR/freetz" ] \
  && fail "$(lang de:"FEHLER: Keine passende Sicherungsdatei" en:"ERROR: Not a valid backup file")"

# restore
if [ "$FAILURE" != "y" ]; then
	echo "$(lang de:"Konfiguration wiederherstellen" en:"Restoring configuration") ..."
	if [ "$FORM_freetz_only" = "on" ]; then
		echo "cat ${INNER_DIR##*/}/freetz > /var/flash/freetz"
		cat $INNER_DIR/freetz > /var/flash/freetz
	else
		for file in $(ls $INNER_DIR); do
			echo "cat ${INNER_DIR##*/}/$file > /var/flash/$file"
			cat $INNER_DIR/$file > /var/flash/$file
		done
	fi
	okay
fi

# cleanup
echo "$(lang de:"Entferne tempor&auml;re Dateien" en:"Removing temporary files") ..."
rm -rf "$OUTER_DIR"
rm -f "$FORM_uploadfile"
echo -e "$(lang de:"ERLEDIGT" en:"DONE")\n"
if [ "$FAILURE" != "y" ]; then
	if [ "$FORM_restart" != "on" ]; then
		echo "$(lang de:"Ein Neustart ist erforderlich" en:"You have to restart")!"
	else
		echo "$(lang de:"Neustart" en:"Restarting") ..."
		touch /tmp/.do_restore.restart
	fi
fi

echo "</pre>"

echo "<p>"
back_button --title="&nbsp;$(lang de:"Zur&uuml;ck" en:"Back")&nbsp;" mod backup
echo "</p>"
cgi_end

[ -e /tmp/.do_restore.restart ] && reboot

%>

