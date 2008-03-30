#!/var/tmp/sh

if [ "$FREETZ" = "0" ]; then
  FREETZ_LINK=""
  USERSCRIPT_LINK="<li><a href=\"dtmfbox_userscript.cgi\" target=\"_new\" >Benutzerdefiniertes Skript</a></li><br>"
  SCRIPT=dtmfbox.cgi
else
  FREETZ_LINK="<hr color=\"black\"></p><li><a href='../'>Freetz</a></li>"
  USERSCRIPT_LINK="<li><a href=\"$SCRIPT?current_page=userscript\" >Benutzerdefiniertes Skript</a></li><br>"
  SCRIPT=""
fi

if [ "$FREETZ" = "0" ]; then
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
		<li><a href="$SCRIPT?current_page=webphone">Webphone</a></li>
		$USERSCRIPT_LINK
		<p></p>
		$FREETZ_LINK
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
if [ "$SCRIPT_NAME" = "$1_save.cgi" ] && [ "$FREETZ" = "0" ];
then
cat << EOF
<form action="$1.cgi" method="post">
EOF
else

if [ "$FREETZ" = "0" ];
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
if [ "$FREETZ" = "0" ]; then
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
fi

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
<ul>
<li><i>Für ISDN:</i> MSN ohne Vorwahl<br>
<li><i>Für Analog:</i> unknown<br>
<li><i>Für VoIP (Type: CAPI):</i> Internettelefonie Account (0-8) + \# + Internetrufnummer (z.B. 0\#12345)<br>
<li><i>Für VoIP (Type: SIP):</i> Die Internetrufnummer<br>
</ul>
</li>

<li><b>DDI</b><p>
Mittels dieser Nummer/Zeichenfolge gelangt man in das Menü.<br><br>

<b><i>Hinweise ISDN:</i></b><br>
<ul>
Bei ISDN Accounts muss im AVM-Webif unter Telefoniegeräte\Festnetz<br>
eine zusätzliche Nummer angelegt werden (z.B. 52). Danach kann man das <br>
interne Menü über **##52 erreichen.
</ul>

<b><i>Hinweise Analog/VoIP:</i></b><br>
<ul>
Für Analog und VoIP Accounts muss der Registrar-Modus verwendet werden.<br>
Dafür wird eine beliebige unbekannte Nummer als DDI verwendet (z.B. 900) und<br>
ein Registrar-Login hinterlegt. Über die Internettelefonie-Einstellungen,<br>
wird sich dann an die dtmfbox angemeldet. Danach kann man, z.B. über *121#900, das<br>
interne Menü erreichen.<br>
</ul>
</li>

<li><b>Type</b><p>
CAPI oder SIP.<br>
Bei SIP müssen folgende Providerdaten hinterlegt werden:
</li>
<ul>
 <li><b>SIP-Registrar</b></li>
 <li><b>Realm</b></li>
 <li><b>Username & Passwort</b></li>
</ul>

<li><b>Registrar-Login</b><p>
Ist der <a href='?help=voip_capi'>Registrar-Modus</a> aktiviert, kann man sich mit einem SIP-Client an die dtmfbox anmelden.<br>
Der CAPI-Controller wird nur bei CAPI-Accounts benötigt und wird für ausgehende Gespräche verwendet.
</li>
</ul>

<p><br>
<b>VoIP Account Beispiele:</b><br>
<ul>
	<li><b>1&1</b><br>
	Name: 49123456789<br>
	MSN, Nr.: 49123456789<br>
	Registrar: 212.227.15.197 <i>(oder sip.1und1.de)</i><br>
	Realm: 1und1.de <i>(oder *)</i><br>
	Username: 49123456789<br>
	Passwort: *******<br>
	ID: 49123456789@1und1.de<br><br>

	<i>Verbindungseinstellungen:</i><br>
	<ul>
	STUN: stun.1und1.de<br>
	STUN-Port: 3478<br>
	ICE: Ja<br>	
	</ul>
	</li><p></p>

	<li><b>Sipgate</b><br>
	Name: 49123456789<br>
	MSN, Nr.: 49123456789<br>
	Registrar: sipgate.de<br>
	Realm: sipgate.de <i>(oder *)</i><br>
	Username: 55112233<br>
	Passwort: *******<br>
	ID: 55112233@sipgate.de
	</li><p></p>
</ul>

<p></p><br>
<b><i>Menü:</i></b><br>
Wird die DDI-Zeichenfolge gewählt, gelangt man in das Menü.<br>
Von Außerhalb kommt man durch die Eingabe des Anrufbeantworter-Pincodes in das Menü.<br><br>

<ul>
<ul>
<li><b><a href='?help=am'>1 = Anrufbeantworter-Menü</a></b><br>
<ul>
  <li>X # = Nachricht X abhören</li>
  <li>0 = Einstellungen</li>
  <ul>
	<li>1 = AB aktivieren/deaktivieren</li>
	<li>2 = Ansagen aufnehmen</li>
	<ul>
	    <li>1 = Ansage aufnehmen</li>	
	    <li>2 = Endansage aufnehmen</li>	
	</ul>
	<li>3 = Alle Aufnahmen löschen</li>
  </ul>
  <li>* = zurück</li>
</ul>

<li><b><a href='?help=dtmf'>2 = DTMF-Befehle</a>:</b><br>
<ul>
  <li><i>Pin # eingeben, falls hinterlegt!</i></li>
  <li>X # = Befehl X ausführen.</li>
  <li>* = zurück</li>
</ul>

<li><b><a href='?help=cbct'>3 = Callthrough/Callback</a></b><br>
<ul>
  <li><i>Pin # eingeben, falls hinterlegt!</i></li>
  <li><i>X # = Account wählen (1-10). 0 = interner S0!</i></li>
  <li><i>Nummer + # wählen. Wenn man sich verschreibt, ein * in der Nummer mitangeben.</i></li>
  <li><i># = Auflegen</i></li>
  <li><i>* = zurück</i></li>
</ul>

<li><b><a href='?help=misc'>4 = Sonstiges</a></b><br>
<ul>
  <li>1 = Fritz!Box</li>
  <ul>
	<li>1 = IP-Adresse</li>
	<li>2 = Uptime</li>
	<li>3 = Uhrzeit</li>
	<li>* = zurück</li>
  </ul>
  <li>2 = Wetter</li>
  <ul>
	<li>1 = Wettervorhersage</li>
	<li>2 = Biowetter</li>
	<li>2 = Wetter Podcast</li>
	<li>* = zurück</li>
  </ul>
  <li>3 = CheckMailD</li>
  <ul>
	<li>1 - 3 = Account 1 bis 3 abfragen</li>
	<li>* = zurück</li>
  </ul>
  <li>4 = Radio</li>
  <ul>
	<li>1 - 5 = Radio-Stream 1 bis 5</li>
	<li>* = zurück</li>
  </ul>
</ul>
</ul>
</ul>
<p>
<b><i>Hinweis:</i></b><br>
Die Menüs können auch direkt erreicht werden.<br>
Die einzelnen Menüs werden mit * getrennt.<br><br>

Beispiel:<br>
- Wettervorhersage: **##1*4*2*1<br>
- DTMF-Befehl 30 (mit PIN): **##1*2*1234#*30#<br>
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

<li><b>Abhebemodus</b><p>
Bestimmt die Art, wie der Anrufbeantworter abheben soll:
<ul>
<li>Alle Anrufer auf AB leiten (Unbekannt und Bekannt)<br>
<li>Nur unbekannte Anrufer auf den AB leiten<br>
<li>Unbekannte Anrufer sofort auf AB leiten, alle bekannten Anrufer erst nach der eingestellten Abhebezeit<br>
</ul>
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
Beim FTP-Server wird <i>kein</i> "ftp://" vorangestellt!<br>
Das Format der Aufnahmen ist: 8000hz, 16Bit Mono (RAW).
</li>
</ul>

<br>
<b><i>Hinweis:</i></b><p>
<ul>
<li>Den AB kann man im Menü 1 erreichen.</li>
<li>Die Einstellungen des AB kann man mit 0 ändern (AB aktivieren/deaktivieren, Ansage/Endansage aufnehmen, Aufnahmen löschen).</li>
<li>Werden die Aufnahmen eines FTP-Streams gelöscht, werden diese auch vom Server entfernt!</li><br>
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
Um ein DTMF Kommando direkt auszuführen (DDI = **##1):<br>
Beispiel: Account 1, Pincode 1234, Befehl 12 = **##1*2*1234#*12#
<p>

EOF
 fi



 if [ "$HELP" = "misc" ];
 then
cat << EOF
<br>
<font size=4><b>Sonstiges</b></font><hr><p>

<ul>
<li><b>(1) Fritz!Box</b><p>
z.Zt. keine Einstellungen<br>
</li>

<li><b>(2) Wetter</b><p>
PLZ und Richtung für die Wettervorhersage.
Wenn madplay hinterlegt wurde, kann zusätzlich ein Wetter-Podcast abgespielt werden.
</li>

<li><b>(3) CheckMailD</b><p>
Falls checkmaild vorhanden ist, kann man den Pfad zur Datendatei (checkmaild.0) hier angeben.<br>
Es kann Absender und Betreff als Display-Message ausgegeben werden.
</li>

<li><b>(4) Radio</b><p>
Um MP3-Radiostreams abspielen zu können, muss madplay installiert sein.<br>
Hier kann der Pfad und die Datei zu madplay angegeben werden.
</li>

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

Eine Callback-Wahlregel besteht aus drei bis vier Teilen:<br>
<pre>
Trigger-Nr. / Callback-Nr. / MSN oder Account ID / Controller
</pre>

<b>Wichtig: Bei SIP Accounts, die nicht über CAPI registriert sind, wird kein Controller angegeben!</b><br><br>

<i>Beispiel:</i><br>
Der Callback soll auf die Rufnummer 004922112345 reagieren. Die Nummer, auf die zurückgerufen werden soll, ist die 0160555555555. Als MSN soll 3322211 verwendet werden (Account 1).<br>
Es wird über Controller 1 raustelefoniert (ISDN):<br>
<pre>
004922112345/0160555555555/3322211/1  # Es wird hier die MSN direkt angegeben
004922112345/0160555555555/1/1        # Es wird hier die MSN als ID (Account 1) übergeben
</pre>
<p>
Man kann auch Regular Expressions verwenden:
<pre>
.*12345/0160555555555/3322211/1       # Rückruf auf bestimmte Nummer (CAPI, mit Controller)
.*12345/0160555555555/3322211         # Rückruf auf bestimmte Nummer (VOIP, ohne Controller)
\(.*\)/\1/1/1                         # Rückruf auf jede Anrufernummer
\(.*\)12345/\112345/1/1               # Rückruf auf Anrufernummer (mit Prüfung des Suffix)
</pre>
</li>

<li><b>Pincode</b><p>
Der Pincode, welcher vorher abgefragt werden soll. Falls kein Pin hinterlegt, wird die Passwortabfrage übersprungen.
</li>
<p>

</ul>

<br>
<b><i>Hinweis:</i></b><p>
Bei CAPI Rückruf vorher das Präfix für Landes- und Ortsvorwahl hinterlegen! Siehe <a href='?help=voip_capi'>Verbindungseinstellungen</a>.<br>
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
Start-Port der RTP/RTCP Ports.<br>
Für jede Verbindung werden jeweils zwei Ports benötigt.<br>
Es können max. 20 Verbindungen hergestellt werden, also sind 40 Ports nötig.
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
<font size=3><b>CAPI (ISDN/Analog/VoIP)</b></font>
<ul>
<li><b>CAPI-Controller 1-5</b><p>
Hier können die CAPI-Controller hinterlegt werden.<br>
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

</ul>

EOF
 fi


 if [ "$HELP" = "webphone" ];
 then
cat << EOF
<br>
<font size=4><b>Webphone</b></font><hr><p>
Ein webbasiertes Softphone in der Testphase.<br>
Einfach einen Account auswählen und die Zielrufnummer eingeben.<br>
Es wird das Standard Sounddevice verwendet.<br><br>

Für das Webphone wird die Java Runtime Engine benötigt.<br>
Download hier: <a href="http://www.java.com/de/download/">http://www.java.com/de/download/</a>
EOF
 fi

 if [ "$HELP" = "userscript" ];
 then
cat << EOF
<br>
<font size=4><b>Benutzerdefinierte Skripte / Addons</b></font><hr><p>
Über das benutzerdefinierte Skript hat man die Möglichkeit, bestimmte Aktionen zu ändern, bzw.<br>
ganz neue Steuerungen zu implementieren.<br><br>

Die dtmfbox ruft das Skript bei Telefonie-Ereignissen auf und übergibt bestimmte Werte als Parameter:
<ul>
<table border="1" cellpadding="3" cellspacing="0" width="100%">
<tr><td colspan="2" bgcolor="silver"><b>\$EVENT</b></td></tr>
<tr>
	<td width="120px"><b>CONNECT</b></td>
	<td>Das erste Ereigniss, welches ausgelöst wird.<br>
	Bei eingehenden Gesprächen signalisiert dieses Ereigniss einen ankommenden Anruf. Die Anrufernummer
	steht in \$DST_NO. Bei ausgehenden Gesprächen steht die Zielrufnummer erst mit dem "EARLY"-Event fest.
	<br>
	</td>
</tr>
<tr>
	<td width="120px"><b>DDI</b></td>
	<td>Eine Wählzeichenfolge wurde empfangen (Blockwahl/Einzelwahl).<br>
	Wurde kein Trenner festgelegt, wird jede Ziffernfolge einzeln an das Skript übergeben.
	</td>
</tr>
<tr>
	<td width="120px"><b>EARLY</b></td>
	<td>
	Dieses Ereigniss wird nur bei ausgehenden Gesprächen ausgelöst.<br>
	Es wurde gewählt und die Zielrufnummer steht fest (\$DST_NO).<br>
	</td>
</tr>
<tr>
	<td width="120px"><b>CONFIRMED</b></td>
	<td>Das Gespräch wurde angenommen.
	</td>
</tr>
<tr>
	<td width="120px"><b>DTMF</b></td>
	<td>Es wurde eine DTMF-Zeichenfolge empfangen.<br>
	Wurde kein Trenner festgelegt, wirde jedes DTMF-Zeichen einzeln an das Skript übergeben (\$DTMFBOX \$SRC_CON -delimiter none)
	</td>
</tr>
<tr>
	<td width="120px"><b>UNCONFIRMED</b></td>
	<td>Das Gespräch wird gehalten / getrennt.
	</td>
</tr>
<tr>
	<td width="120px"><b>DISCONNECT</b></td>
	<td>Das Gespräch wurde getrennt.
	</td>
</tr>
</table>
<p></p>

<table border="1" cellpadding="3" cellspacing="0" width="100%">
<tr><td colspan="2" bgcolor="silver"><b>\$TYPE</b></td></tr>
<tr>
	<td width="120px"><b>VOIP</b></td>
	<td>VoIP Verbindung</td>
</tr>
<tr>
	<td width="120px"><b>CAPI</b></td>
	<td>ISDN/Analog Verbindung</td>
</tr>
<tr>
	<td width="120px"><b>USER</b></td>
	<td>Client Verbindung (Registrar-Mode)</td>
</tr>
</table>
<p></p>

<table border="1" cellpadding="3" cellspacing="0" width="100%">
<tr><td colspan="2" bgcolor="silver"><b>\$IN_OUT</b></td></tr>
<tr>
	<td width="120px"><b>INCOMING</b></td>
	<td>Eingehende Verbindung</td>
</tr>
<tr>
	<td width="120px"><b>OUTGOING</b></td>
	<td>Ausgehende Verbindung</td>
</tr>
</table>
<p></p>

<table border="1" cellpadding="3" cellspacing="0" width="100%">
<tr><td colspan="2" bgcolor="silver"><b>\$SRC_CON</b></td></tr>
<tr>
	<td colspan="2">Die ID der aktuellen Verbindung.</td>
</tr>
</table>
<p></p>

<table border="1" cellpadding="3" cellspacing="0" width="100%">
<tr><td colspan="2" bgcolor="silver"><b>\$DST_CON</b></td></tr>
<tr>
	<td colspan="2">Die ID des Gesprächspartners (wenn zwei Anrufe miteinander verbunden wurden, ansonsten "-1").</td>
</tr>
</table>
<p></p>

<table border="1" cellpadding="3" cellspacing="0" width="100%">
<tr><td colspan="2" bgcolor="silver"><b>\$SRC_NO</b></td></tr>
<tr>
	<td colspan="2">Eigene Nummer (Account-Nummer)</td>
</tr>
</table>
<p></p>

<table border="1" cellpadding="3" cellspacing="0" width="100%">
<tr><td colspan="2" bgcolor="silver"><b>\$DST_NO</b></td></tr>
<tr>
	<td colspan="2">Die Nummer des Anrufers (INCOMING), bzw. Zielrufnummer (OUTGOING)</td>
</tr>
</table>
<p></p>

<table border="1" cellpadding="3" cellspacing="0" width="100%">
<tr><td colspan="2" bgcolor="silver"><b>\$ACC_NO</b></td></tr>
<tr>
	<td colspan="2">Account-ID (1-10)</td>
</tr>
</table>
<p></p>

<table border="1" cellpadding="3" cellspacing="0" width="100%">
<tr><td colspan="2" bgcolor="silver"><b>\$DTMF</b></td></tr>
<tr>
	<td colspan="2">DTMF/DDI-Zeichenfolge</td>
</tr>
</table>
<p></p>
</ul>

Das benutzerdefinierte Skript wird an verschiedenen Stellen im Programm aufgerufen. Deswegen kann es vorkommen,
dass der selbe Event zwei bis drei Mal ausgelöst wird. Dies sollte man im eigenen Skript berücksichtigen und ggf. einschränken:<br>
<ul>
<li><b>if [ "\$SCRIPT" = "BEFORE_LOAD" ]; then ...</b><br>
Skript wird am Anfang der script_funcs.sh aufgerufen (Global)</li><br>
<li><b>if [ "\$SCRIPT" = "FUNCS" ]; then ...</b><br>
Skript wird am Ende der script_funcs.sh aufgerufen (Global)</li><br>
<li><b>if [ "\$SCRIPT" = "AM" ]; then ...</b><br>
Skript wird vor dem Anrufbeantworter Vorgang aufgerufen (script_am.sh)</li><br>
<li><b>if [ "\$SCRIPT" = "CT" ]; then ...</b><br>
Skript wird vor dem Callthrough Vorgang aufgerufen (script_main.sh)</li><br>
<li><b>if [ "\$SCRIPT" = "CB" ]; then ...</b><br>
Skript wird vor dem Callback Vorgang aufgerufen (script_main.sh)</li><br>
</ul>

<b>1. Beispiel:</b><br><br>
Bei einem Anruf auf die Account-Nr. "12345" soll das Gespräch sofort angenommen werden.
Es wird eine Wave-Datei abgespielt und danach wieder aufgelegt.<br>
<pre>
if [ "\$SCRIPT" = "BEFORE_LOAD" ];
then
  if [ "\$SRC_NO" = "12345" ] && [ "\$EVENT" = "CONNECT" ] && [ "\$IN_OUT" = "INCOMING" ];
  then
	\$DTMFBOX \$SRC_CON -hook up
	\$DTMFBOX \$SRC_CON -play /var/meine_wave.wav
	\$DTMFBOX \$SRC_CON -hook down
	return 1
  fi
fi
</pre>
Möchte man das Skript für bestimmte Anrufer eingrenzen, muss zusätzlich \$DST_NO abgefragt werden.
<p></p>

<b>2. Beispiel:</b><br><br>
Man möchte den eMail-Text des Anrufbeantworters ändern. Man kann dafür die vorhandene Funktion
create_mail() in script_am.sh überladen:

<pre>
if [ "\$SCRIPT" = "AM" ];
then
create_mail() {

cat &lt;&lt; SUBEND &gt; &quot;\$DTMFBOX_PATH/tmp/\$SRC_CON.mail_subject.txt&quot;
  Mein eigener Betreff (von Nr. \$DST_NO an Nr. \$SRC_NO)
SUBEND

cat &lt;&lt; MAILEND &gt; &quot;\$DTMFBOX_PATH/tmp/\$SRC_CON.mail_body.html&quot;
  &lt;html&gt;
  &lt;head&gt;&lt;title&gt;Ein Titel&lt;/title&gt;&lt;/head&gt;
  &lt;body&gt;
  &lt;h3&gt;&lt;b&gt;Anrufbeantworter&lt;/b&gt;&lt;br&gt;&lt;/h3&gt;
  Anruf (\$TYPE)&lt;br&gt;
  von \$DST_NO für \$SRC_NO&lt;br&gt;
  &lt;/body&gt;&lt;/html&gt;
MAILEND

MAIL_SUBJECT=\`cat &quot;\$DTMFBOX_PATH/tmp/\$SRC_CON.mail_subject.txt&quot;\`
}
fi
</pre>
<p></p><br>

<b>Weitere Beispiele / Addons:</b><br><br>
Unter $DTMFBOX_PATH/script/addons befinden sich Addons, welche optional
eingebunden werden können.<p>

<ul>
<li><b>script/addons/zdf_podcast.sh</b><p>
Nach Einbindung des Skriptes befindet sich im internen Menü unter Sonstiges (4) ein neuer Untermenüpunkt (5).
<pre>
. ./script/addons/zdf_podcast.sh
</pre>
</li>

<li><b>script/addons/anti_callcenter.sh</b><p>
Nach Einbindung des Skriptes werden alle unbekannten Anrufe sofort entgegengenommen und der Anrufer veranlasst, 
seine Telefonnummer + # einzugeben. Danach wird er mit der Zielrufnummer weiterverbunden (ggf. über CAPI-Controller X).</li><br>
<pre>
. ./script/addons/anti_callcenter.sh &lt;ANSAGE-WAVE&gt; &lt;MUSIK-WAVE&gt; &lt;ZIELRUFNUMMER&gt; &lt;CAPI-CONTROLLER&gt;
if [ "\$?" = "1" ]; then return 1; fi

. ./script/addons/anti_callcenter.sh "\$DTMFBOX_PATH/play/bitte_nummer_eingeben.wav" "\$DTMFBOX_PATH/play/musik.wav" "12345" "3"
if [ "\$?" = "1" ]; then return 1; fi
</pre>

<li><b>script/addons/isdn_mod.sh</b><p>
Mithilfe dieses Skriptes wird eine externe MSN mit einer internen MSN verbunden.<br>
Damit hat man die Möglichkeit eine Rückwärtssuche durchzuführen und das Ergebnis als Display-Message am Telefon anzuzeigen.
Am Telefon muss man dafür als Empfangs-MSN eine Pseudo-MSN angeben (z.B. 602). Die Sende-MSN kann weiterhin bestehen bleiben.<br>
Soll auch die Sende-MSN über die dtmfbox durchgereicht werden, muss im AVM-WebIf ein VoIP Account ohne Registrierungsdaten hinterlegt werden (Inetrufnummer: 602).
Dieser Account wird ebenfalls in der dtmfbox eingerichtet (z.B. MSN: 0#602, CAPI-Ctrl. 5). 

<pre>
# . ./script/addons/isdn_mod.sh &lt;ACCOUNT-ID&gt; &lt;REAL-MSN&gt; &lt;EMPFANGS-MSN&gt; &lt;SENDE-MSN&gt; &lt;AVM-WEBIF PASSWORT&gt; 
# if [ "\$?" = "1" ]; then return 1; fi

##############################################################################
# nur Empfangs-MSN durchreichen (über S0):
##############################################################################
. ./script/addons/isdn_mod.sh "1" "12345" "602"
if [ "\$?" = "1" ]; then return 1; fi

##############################################################################
# Empfangs- und Sende-MSN durchreichen (über S0 und VoIP Account 0#602):
# Hinweis: 0#... = erster VoIP-Account, 1#... = zweiter VoIP-Account, usw.
##############################################################################
. ./script/addons/isdn_mod.sh "1" "12345" "602" "0#602"
if [ "\$?" = "1" ]; then return 1; fi

##############################################################################
# Empfangs-MSN durchreichen (über SIP an voipd):
##############################################################################
. ./script/addons/isdn_mod.sh "1" "12345" "602@localhost" "" "passwort"
if [ "\$?" = "1" ]; then return 1; fi
</pre>
Als Empfangs-MSN kann man auch eine SIP-Uri angegeben. Bei einer SIP-Uri muss man ebenfalls einen leeren VoIP-Account im AVM-WebIf hinterlegen. Der Anruf wird dann per SIP weitergereicht, anstatt über den internen S0. 
Hierbei muss das WebIf-Passwort mitangegeben werden, damit ein Telefonbucheintrag für die Rückwärtssuche erstellt werden kann (es wird der erster TB-Eintrag überschrieben!).
<p></p>

<i>Rückwärtssuche</i>:<br>
Zunächst wird geschaut, ob ein Eintrag in $DTMFBOX_PATH/phonebook.txt gefunden werden kann. Wurde kein Eintrag gefunden,
wird ein Userskript-Event ausgelöst (\$SCRIPT="INVERS"). Hier kann man seine eigene Rückwärtssuche
durchführen und das Ergebnis mit "echo" ausgeben. Wird kein Eintrag ausgeben, wird eine Rückwärtssuche
über dasoertliche.de durchgeführt.<br>
Die Datei phonebook.txt hat folgendes Format:<br>
<pre>
nummer|display-text
03012345|Ein Eintrag
021133412|Weiterer Eintrag
...
</pre>

Das Userskript zur Rückwärtssuche könnte folgendermaßen aussehen:<br>
<pre>
if [ "\$SCRIPT" = "INVERS" ];
then
  if [ "\$DST_NO" = "03012345" ]; then echo "Ein Eintrag"; fi
  if [ "\$DST_NO" = "021133412" ]; then echo "Weiterer Eintrag"; fi
  return 1;
fi
</pre>
</ul>


EOF
 fi

cat << EOF
</div><div style='display:none'>
EOF
}

# ------------------------------------------------

cgi_begin "$package" "pkg_$package"
frm_begin "$package"
