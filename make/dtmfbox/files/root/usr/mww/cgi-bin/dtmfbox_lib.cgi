# dsmod or usb version?
if [ "$DSMOD" = "0" ]; then  
  DSMOD_LINK=""
  USERSCRIPT_LINK="<li><a href=\"dtmfbox_userscript.cgi\" target=\"_new\" >Benutzerdefiniertes Skript</a></li><br>"
  SCRIPT=dtmfbox.cgi
else
  DSMOD_LINK="<hr color=\"black\"></p><li><a href='../'>DS-MOD</a></li>"
  USERSCRIPT_LINK="<li><a href=\"$SCRIPT?current_page=userscript\" >Benutzerdefiniertes Skript</a></li><br>"
  SCRIPT=""
fi

# libmodcgi.sh
let _cgi_width=730
if [ "$cgi_width" -gt 0 ]; then let _cgi_width="$cgi_width"; fi
let _cgi_total_width="$_cgi_width+40"

cgi_begin() {

cat << EOF
  Content-Type: text/html


  <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
     "http://www.w3.org/TR/html4/loose.dtd">
  <html>
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
  <meta http-equiv="Content-Language" content="de">
  <meta http-equiv="Expires" content="0">
  <meta http-equiv="Pragma" content="no-cache">
  <title>$1</title>
  <link rel="stylesheet" type="text/css" href="../style.css">
  </head>
  <body>
EOF

# menu change javascript
cat << EOF
  <a name="top" href="#top"></a>
  <table border="0" cellspacing="0" cellpadding="0" align="center" width="95%">
  <tr>
  <td width="500" bgcolor="blue" width="70%">
    <div class="title" align="left"><span style="font-style: italic;">$1</span></div>
  </td>
  <td bgcolor="blue" width="30%">
    <div class="version" align="right">$DTMFBOX_VERSION</div>
  </td>
  </tr>
  <tr>
  <td width="70%" id="content" valign="top">

EOF

}

cgi_end() {
cat << EOF
</td>
<td valign="top">
	<table border="0" cellpadding="3" cellspacing="0"> 
	<tr><td width="20" height="20"></td><td>
	<tr><td width="20"></td><td>
	<div align="left">
	<ul>
		<li><a href="$SCRIPT?current_page=status">Status</a></li>
		<p></p>
		<li><a href="$SCRIPT?current_page=accounts">Accounts</a></li>
		<li><a href="$SCRIPT?current_page=voip_capi">Verbindungseinstellungen</a></li>
		<p></p>
		<li><a href="$SCRIPT?current_page=am">Anrufbeantworter</a></li>
		<li><a href="$SCRIPT?current_page=dtmf">DTMF-Commands</a></li>
		<li><a href="$SCRIPT?current_page=cbct">Callback & Callthrough</a></li>
		<li><a href="$SCRIPT?current_page=misc">Sonstiges</a></li>
		<p></p>
		$USERSCRIPT_LINK
		<p></p>
		$DSMOD_LINK
	</ul>
	</div>
	</td></tr></table>
</td>
</tr>
<tr>
</table>
</body>
</html>
EOF
}

sec_begin() {
cat << EOF
<div>
<fieldset style="width:97%">
<legend>$1</legend>
EOF
}

sec_end() {
cat << EOF
</fieldset>
</div>
EOF
}

# libmodfrm.sh
frm_begin() {
if [ "$SCRIPT_NAME" = "$1_save.cgi" ] && [ "$DSMOD" = "0" ];
then
cat << EOF
<form action="$1.cgi" method="post">
EOF
else

if [ "$DSMOD" = "0" ]; 
then
cat << EOF
	<form action="$1_save.cgi?form=pkg_$1" method="post">
EOF

else

cat << EOF
	</form>
	<form action="/cgi-bin/save.cgi?form=pkg_$1" method="post">
EOF

fi

fi
}

frm_end() {
if [ "$DSMOD" = "0" ]; then
cat << EOF
  <input type="hidden" name="form" value="pkg_$1">
  <input type="hidden" name="dummy" value="0">
  <div class="btn"><input type="submit" value="&Uuml;bernehmen" style="width:150px"></div>
  </form>
  
  <form class="btn" action="$1_save.cgi?form=pkg_$1&uninstall=1" method="post">
  <div class="btn"><input type="button" onclick="javascript:ans=confirm('Uninstall dtmfbox?'); if(ans == true) { location.href='dtmfbox_save.cgi?form=pkg_$1&uninstall=1'; }" value="Uninstall" style="width:150px"></div>
  <input type="hidden" value="1" name="uninstall" id="uninstall">
  </form>   
EOF

else
cat << EOF
  <input type="hidden" name="form" value="pkg_$1">
  <input type="hidden" name="last_page" value="$CURRENT_PAGE">
  <input type="hidden" name="dummy" value="0">
  <div class="btn" id="save"><input type="submit" value="&Uuml;bernehmen"></div>
  </form>
  <form class="btn" action="/cgi-bin/save.cgi?pkg=$1">
  <input type="hidden" name="form" value="def_$1">
  <div class="btn" id="default"><input type="submit" value="Standard"></div>
  </form>
EOF
fi
}

# ------------------------------------------------
# Help
# ------------------------------------------------

show_help() {

 if [ "$HELP" = "status" ];
 then
cat << EOF
<br>
<font size=4><b>Status</b></font><hr><p>
Der aktuelle Dienststatus der dtmfbox.<br><br>
Wird der Dienst als 'geloggt' gestartet ("Starten (Log)"), so kann über die Schaltfläche "Log ansehen" die Logdatei ausgegeben werden. Das Loglevel lässt sich von 0 (nichts) bis 5 (alles) einstellen.<br><br>

Wurde der Dienst gestartet, so werden die Accounts, Verbindungen und registrierten Clients (<a href='?help=voip_capi'>Registrar-Mode</a>) mitangezeigt.<br>

<li><b>Startmodus</b><p>
dtmfbox automatisch starten oder manuell.<br>
Der manuelle Start erfolgt über das Webinterface, bzw. über die Konsole:<br>
<pre>
/etc/init.d/rc.dtmfbox [start] [stop] [restart]
</pre>

<li><b>USB-Pfad</b><p></li>
Wird ein USB-Speicher verwendet, so kann hier der Pfad angegeben werden. 
Falls kein USB vorhanden ist, leer lassen!


EOF
 fi

 if [ "$HELP" = "accounts" ];
 then
cat << EOF
<br>
<font size=4><b>Accounts</b></font><hr><p>
Es können max. 10 Accounts hinterlegt werden (ISDN/Analog/VoIP).<br><br>

<ul>
<li><b>Aktiv</b><p>
Account aktivieren / deaktivieren
</li>

<li><b>Name</b><p>
Beliebiger Name. Bei VoIP wird dieser an die SIP Uri vorangestellt.<br>
</li>

<li><b>MSN</b><p>
Bei ISDN: MSN ohne Vorwahl<br>
Bei Analog: unknown<br>
Bei VoIP: Die Internetrufnummer<br>
</li>

<li><b>Type</b><p>
ISDN/Analog oder VoIP.<br>
Bei VoIP müssen folgende Providerdaten hinterlegt werden:
</li>
<ul>
 <li><b>SIP-Registrar</b></li>
 <li><b>Realm</b></li>
 <li><b>Username & Passwort</b></li>
</ul>

<li><b>Registrar-Login</b><p>
Ist der <a href='?help=voip_capi'>Registrar-Modus</a> aktiviert, kann man sich mit einem SIP-Client an die dtmfbox
anmelden. Es werden dafür die hier hinterlegten Anmeldedaten verwendet. 
</li>
</ul>

<p></p><br>
<b><i>Hinweis:</i></b><br>
Falls die Registrierung beim Provider nicht funktioniert, kann optional eine ID hinterlegt werden.<br>
z.B. <i>username@sip.registrar.de</i> oder nur <i>username</i> (der Hostteil wird automatisch angehangen)<br><br>

Ist die Registrierung erfolgreich, aber es werden keine Anrufe signalisiert oder es besteht nur eine einseitige
Verbindung (One-Way-Audio), so sollte ein <a href='?help=voip_capi'>STUN-Server</a> hinterlegt werden.

<p></p><br>
<b><i>Menü:</i></b><br>
Über die Kurzwahlen *#001# (Acc. 1) bis *#010# (Acc. 10) gelangt man in das Hauptmenü (intern, nur ISDN!).<br>
Von Außerhalb kommt man nach Eingabe des AB-PINs in das Hauptmenü.<br><br>

Hier werden alle Befehle mit # (Raute) abgeschlossen. In vorherige Menüs, gelangt man mit *#.<br>

<ul>
<ul>
<li><b><a href='?help=am'>1# = AB-Menü</a></b><br>
<ul>
  <li>X # = Nachricht abhören</li>
  <li>0 # = Einstellungen</li>
  <ul>
    <li>1 # = AB aktivieren/deaktivieren</li>
    <li>2 # = Ansagen aufnehmen</li>
	<ul>
	    <li>1 # = Ansage aufnehmen</li>	
	    <li>2 # = Endansage aufnehmen</li>	
	</ul>
    <li>3 # = Alle Aufnahmen löschen</li>
  </ul>
</ul>

<li><b><a href='?help=dtmf'>2# = DTMF-Commands</a>:</b><br>
<ul>
  <li><i>Pin # eingeben, falls hinterlegt!</i></li>
  <li>1 - 50 # = Befehl X ausführen.</li>
</ul>

<li><b><a href='?help=cbct'>3# = Callthrough (Callback)</a></b><br>
<ul>
  <li><i>Pin # eingeben, falls hinterlegt!</i></li>
  <li><i>Account wählen (1-10 #). 0 = interner S0!</i></li>
  <li><i>Nummer # wählen. Wenn man sich verschreibt, ein * in der Nummer mitangeben.</i></li>
  <li><i>*# = Auflegen und zurück zur Accountwahl.</i></li>
</ul>

<li><b><a href='?help=misc'>4# = Sonstiges</a></b><br>
<ul>
  <li>1 # = Fritz!Box</li>
  <ul>
    <li>1 # = IP-Adresse</li>
    <li>2 # = Uptime</li>
    <li>3 # = Uhrzeit</li>
  </ul>
  <li>2 # = Wetter</li>
  <ul>
    <li>1 # = Wettervorhersage</li>
    <li>2 # = Biowetter</li>
  </ul>
</ul>
</ul>
</ul>
<p>
<b><i>Hinweis:</i></b><br>
Die Menüs können auch direkt erreicht werden.<br>
Die einzelnen Menüs werden mit * getrennt und am Ende ein # zur Bestätigung angegeben.<br><br>

Beispiel Wettervorhersage: *#001*4*2*1#
EOF
 fi


if [ "$HELP" = "am" ];
 then
cat << EOF
<br>
<font size=4><b>Anrufbeantworter</b></font><hr><p>

<ul>
<li><b>Aktiv</b><p>
Anrufbeantworter aktivieren / deaktivieren
</li>

<li><b>Pincode</b><p>
Pincode für die Fernabfrage.
</li>

<li><b>Aufnahmemodus</b><p>
Wann soll aufgenommen werden?<br>
<ul>
<li> An (direkt nach dem Abheben aufnehmen)</li>
<li> Later (nach Ansage aufnehmen)</li>
<li> Aus (nur Ansage abspielen, keine Aufnahme)</li>
</ul>
</li>

<li><b>Aufnahmezeit</b><p>
Wie lange soll aufgenommen werden (in sec, 0=unendlich)?
</li>

<li><b>Abhebezeit</b><p>
Wie lange soll gewartet werden, bevor abgehoben wird (in sec)?
</li>

<li><b>Ansage & Endansage</b><p>
Hier kann entweder ein Pfad oder eine URL (http://, ftp://) angegeben werden.<br>
Wird eine URL angegeben, muss die Datei 8000hz, 16bit, Mono als Format besitzen (WAVE/RAW).<br>
Die Endansage wird nach der Aufnahmezeit abgespielt.<br>
</li>

<li><b>Piepton nach Ansage</b><p>
Soll ein Piepton nach der Ansage abgespielt werden?
</li>

<li><b>Nur unbekannte Anrufer</b><p>
Es werden nur anonyme Anrufer auf den AB geleitet.
</li>


<li><b>Schedule</b><p>
AB soll nur zu bestimmten Zeiten aktiv sein.
xx:xx Uhr anschalten - xx:xx Uhr ausschalten
</li>

<li><b>Aufnahmen per eMail versenden</b><p>
Wenn die Aufnahmen per eMail verschickt werden sollen, muss ein Mailaccount hinterlegt werden.<br>
Die Aufnahmen werden dabei auf USB, bzw. auf der FB abgelegt und ggf. gelöscht (Löschen nach Versand).<br>
Das Format der Aufnahmen ist: 8000hz, 16Bit Mono (WAVE)
</li>

<li><b>Aufnahmen auf FTP-Server ablegen</b><p>
Die Aufnahmen werden auf einen FTP-Server abgelegt.<br>
Das Format der Aufnahmen ist: 8000hz, 16Bit Mono (RAW). 
</li>
</ul>

<br>
<b><i>Hinweis:</i></b><p>
<ul>
<li>Den AB kann man auch über die Kurzwahlen *#001*1# (Acc. 1) bis *#010*1# (Acc. 10) erreichen.<br>
Um die erste Ansage, von Account 1, direkt abzuspielen: *#001*1*1#</li><br>

<li>Die Einstellungen kann man mit 0# im AB-Menü erreichen.</li><br>

<li>Werden die Aufnahmen eines FTP-Streams gelöscht, werden diese auch vom Server entfernt!</li><br>

<li>Wenn keine Ansage hinterlegt wurde, werden drei Beeps abgespielt.</li><br>

</ul>
<p>
EOF
fi



 if [ "$HELP" = "dtmf" ];
 then
cat << EOF
<br>
<font size=4><b>DTMF-Commands</b></font><hr><p>

<ul>
<li><b>Pincode:</b><p>
Der Pincode um DTMF Kommandos auszuführen. 
</li>

<li><b>DTMF-Commands</b><p>
Hierüber kann man eigene (kurze) Skripts ausführen (z.B. WOL, Dienste neu starten, Anruf durchführen, etc.).<br>
Es können max. 50 Befehle hinterlegt werden (1# - 50#).<br>
Um einen Text in Sprache wiederzugeben, kann die Funktion say_or_beep "Text" verwendet werden.<br>
</li>
</ul>

<br>
<b><i>Hinweis:</i></b><p>
Um ein DTMF Kommando direkt auszuführen:<br>
Beispiel: Account 1, Pincode 1234, Befehl 12 = *#001*2*1234*12
<p>

EOF
 fi



 if [ "$HELP" = "misc" ];
 then
cat << EOF
<br>
<font size=4><b>Sonstiges</b></font><hr><p>

<ul>
<li><b>Wetter</b><p>
PLZ und Richtung für die Wettervorhersage.
</li>

<p></p>
<b><i>Hinweis:</i></b><br>
Momentan befinden sich nur die Menüs "Fritz!Box" und "Wetter" unter Sonstiges.<br>
EOF
 fi

 if [ "$HELP" = "cbct" ];
 then
cat << EOF
<br>
<font size=4><b>Callback & Callthrough</b></font><hr><p>

<ul>
<li><b>Callback</b><p>
Anrufen & Auflegen (Der Rückruf erfolgt nach dem Auflegen)
</li>

<li><b>Callthrough</b><p>
Anrufen
</li>

<li><b>Trigger-Nr.</b><p>
Es können mehrere Trigger-Nr., bzw. Callback-Wahlregeln definiert werden (durch Leerzeichen getrennt).<br><br>

Eine Callback-Wahlregel besteht aus ein bis drei Teilen:<br>
<pre>
Trigger-Nr/Callback-Nr/MSN
</pre>
Callback-Nr und MSN können auch weggelassen werden.<p>

<i>Beispiel:</i><br>
Der Callback soll auf die Rufnummer 004922112345 reagieren. Die Nummer, auf die zurückgerufen werden soll, ist die 0160555555555. Als MSN (Account) soll 3322211 verwendet werden.<br>
<br>
Die Wahlregel könnte dann so aussehen:<br>
<pre>
004922112345/0160555555555/3322211
</pre>
<p>
Bei der Trigger-Nr. kann man auch Regular Expressions verwenden:
<pre>
.*12345/0160555555555/3322211       # Rückruf auf bestimmte Nummer mit MSN
\(.*\)/\1                           # Rückruf auf beliebige Nummer
</pre>
</li>

<li><b>Pincode</b><p>
Der Pincode, welcher vorher abgefragt werden soll. Falls kein Pin hinterlegt, wird die Passwortabfrage übersprungen.
</li>
<p>

</ul>

<br>
<b><i>Hinweis:</i></b><p>
Bei CAPI Rückruf vorher Präfix International/National unter den <a href='?help=voip_capi'>Verbindungseinstellungen</a> hinterlegen!<br>
<p>

EOF
fi

 if [ "$HELP" = "voip_capi" ];
 then
cat << EOF
<br>
<font size=4><b>Verbindungseinstellungen </b></font><hr><p>

<br>
<font size=3><b>SIP (VoIP)</b></font>
<ul>
<li><b>VoIP verwenden</b><p>
VoIP (SIP) an-/ausschalten
</li>

<li><b>Registrar-Modus</b><p>
Die dtmfbox als Registrar verwenden.<br>
Die Anzahl der max. Clients die sich anmelden dürfen, werden rechts daneben eingetragen.<br>
Unter den <a href='?help=accounts'>Accounts</a> können die Anmeldedaten hinterlegt werden.
</li>

<li><b>UDP Server Port</b><p>
Der Port, welcher dem SIP Server zugewiesen werden soll (SIP-Messages).
</li>

<li><b>RTP/RTCP Start Port</b><p>
Start-Port und Anzahl der RTP/RTCP Verbindungen für Media.<br>
Für jede Verbindung werden jeweils zwei Ports benötigt.
</li>

<li><b>Re-Register Intervall</b><p>
Zeitintervall, wann eine Neuregistrierung beim SIP-Provider durchgeführt werden soll.
</li>

<li><b>Keep-Alive Intervall</b><p>
In welchen Abständen sollen Dummy-Messages an den Server geschickt werden, um die Verbindung aufrecht zu erhalten.
</li>

<li><b>VAD (silence detector)</b><p>
Sprachpausen-Erkennung an/aus
</li>

<li><b>Interface (optional)</b><p>
Interface, an welches die Sockets gebunden werden sollen (IP/Hostname)
</li>

<li><b>STUN Server</b><p>
STUN Server (NAT)
</li>

<li><b>ICE verwenden</b><p>
Soll ICE (Interactive Connectivity Establishment) verwendet werden?<br>
Es muss ein STUN Server hinterlegt sein, um ICE zu verwenden!
</li>
</ul>

<br>
<font size=3><b>CAPI (ISDN/Analog)</b></font>
<ul>
<li><b>CAPI-Controller</b><p>
Der eingehende, ausgehende und interne Controller der CAPI-Schnittstelle (ISDN/Analog).
</li>

<li><b>Präfix International / National</b><p>
Bei eingehenden CAPI Anrufen, wird der Ländercode und die Ortsvorwahl an die Nr. vorangestellt.<br>
</li>
</ul>

<br>
<font size=3><b>Audio</b></font>
<ul>
<li><b>Wählton</b><p>
Es wird ein Wählton beim Verbindungsaufbau mit einem anderen Gesprächspartner abgespielt.<br>
</li>

<li><b>RX-Volume</b><p>
Empfangslautstärke für alle Verbindungen (0-200)<br>
</li>

<li><b>TX-Volume</b><p>
Sendelautstärke für alle Verbindungen (0-200)<br>
</li>

<li><b>Echo Canceller Tail Length</b><p>
Echo Canceller für alle Verbindungen (experimentell).<br>
Eine Echo-Länge von 20ms sollte ein guter Startwert sein.
</li>
</ul>

<br>
<font size=3><b>eSpeak (Text-to-Speech)</b></font>
<ul>
<li><b>eSpeak</b><p>
- eSpeak ausschalten (Beep)<br>
- eSpeak Web-Stream (Online-Sprachausgabe, inkl. mbrola)<br>
- eSpeak (Installiert, ohne mbrola)<br>
<br>
<b><i>Hinweis:</i></b> "eSpeak (Installiert)" wird nur angezeigt, wenn eSpeak unter<br>
"$DTMFBOX_PATH/espeak" oder "/usr/bin" gefunden wurde.

<li><b>Stimme</b><p>
Männlich/Weiblich und Voice-Type. mbrola ist nur im Web-Stream Modus verfügbar!

<li><b>Geschwindigkeit</b><p>
Geschwindigkeit in der gesprochen werden soll.

<li><b>Pitch</b><p>
Hohe/Tiefe Stimme.
</ul>

<br>
<font size=3><b>Sonstiges</b></font>
<ul>
<li><b>DDI Präfix</b><p>
DDI Präfix, welches bei interner Wahl vorangestellt werden soll.<br>
Beispiel (Account 2): *# = *#002#, *0 = *0002# <br>

</ul>
 
EOF
 fi
}

# ------------------------------------------------

cgi_begin "$package" "pkg_$package"
frm_begin "$package"
