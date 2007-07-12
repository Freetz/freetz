DSMOD="1"
www_script="http://fritz.v3v.de/dtmfbox/dtmfbox-0.3.9-standalone/rc.dtmfbox-setup"

package=dtmfbox

# dsmod or mini_httpd?
if [ "$DSMOD" = "0" ]; then  
  DSMOD_LINK=""
  USERSCRIPT_LINK=""
  SCRIPT=dtmfbox.cgi
else
  DSMOD_LINK="<p><hr color="black"></p><li><a href='../'>DS-MOD</a></li>"
  USERSCRIPT_LINK="<li><a href=\"$SCRIPT?current_page=userscript\" >Benutzerdefiniertes Skript</a></li><br>"
  SCRIPT=""
fi

# create urldecode.sed
if [ ! -f /var/tmp/urldecode.sec ]; then
cat > /var/tmp/urldecode.sed << 'ENDURLDECODE'
s/+/ /g
s/%09/	/g
s/%0A/\n/g
s/%0D//g
s/%20/ /g
s/%21/!/g
s/%22/"/g
s/%23/#/g
s/%24/\$/g
s/%25/%/g
s/%26/\&/g
s/%27/'/g
s/%28/(/g
s/%29/)/g
s/%2A/\*/g
s/%2B/+/g
s/%2C/,/g
s/%2D/-/g
s/%2E/\./g
s/%2F/\//g
s/%3A/:/g
s/%3B/;/g
s/%3C/</g
s/%3D/=/g
s/%3E/>/g
s/%3F/?/g
s/%40/@/g
s/%5B/\[/g
s/%5C/\\/g
s/%5D/\]/g
s/%5E/\^/g
s/%5F/_/g
s/%60/`/g
s/%7B/{/g
s/%7C/|/g
s/%7D/}/g
s/%7E/~/g
s/%91/`/g
s/%92/´/g
ENDURLDECODE
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
	<table border="0">
	<tr><td width="20" height="20"></td><td>
	<tr><td width="20"></td><td>
	<div align="left">
	<ul>
		<li><a href="$SCRIPT?current_page=status">Status</a></li><br>
		<li><a href="$SCRIPT?current_page=accounts">Accounts</a></li><br>
		<li><a href="$SCRIPT?current_page=am">Anrufbeantworter</a></li><br>
		<li><a href="$SCRIPT?current_page=cbct">Callback & Callthrough</a></li><br>
		<li><a href="$SCRIPT?current_page=dtmf">DTMF-Commands</a></li><br>
		$USERSCRIPT_LINK
		<li><a href="$SCRIPT?current_page=voip_capi">VoIP- & CAPI-Einstellungen</a></li><br>
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
<fieldset style="width:100%">
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

<li><b>Startmodus</b><p>
dtmfbox automatisch starten oder manuell.<br>
Der manuelle Start erfolgt über das Webinterface, bzw. über die Konsole:<br>
<pre>
/etc/init.d/rc.dtmfbox [start] [stop] [restart]
</pre>
</li>

EOF
 fi

 if [ "$HELP" = "accounts" ];
 then
cat << EOF
<br>
<font size=4><b>Accounts</b></font><hr><p>
Es können max. 10 Accounts hinterlegt werden. <br><br>

<ul>
<li><b>Aktiv</b><p>
Account aktivieren / deaktivieren
</li>

<li><b>Name</b><p>
Beliebiger Name. Bei VoIP wird dieser an die SIP Uri vorangestellt.<br>
</li>

<li><b>MSN</b><p>
ISDN: MSN ohne Vorwahl<br>
Analog: unknown<br>
VoIP: Die Internetrufnummer<br>
</li>

<li><b>Type</b><p>
ISDN/Analog oder VoIP.<br>
Bei VoIP müssen die Providerdaten hinterlegt werden:
</li>
<ul>
 <li><b>SIP-Registrar</b></li>
 <li><b>Realm</b></li>
 <li><b>Username & Passwort</b></li>
</ul>
Falls die Registrierung nicht funktioniert, kann optional der Contact Header und die ID geändert werden.<br>
z.B. <i>username@sip.host.de</i> oder nur <i>username</i> (der Hostteil wird automatisch angehangen)

</ul>

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

<li><b>Aufnahmemodus</b><p>
<ul>
Wann soll aufgenommen werden?<br><br>
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
Die Endansage wird direkt nach der Aufnahmezeit abgespielt. Danach legt der AB auf.<br>
Die Aufnahmen haben das Format Wave, 8khz, 16 Bit, Mono. 
</li>

<li><b>Piepton nach Ansage</b><p>
Soll ein Piepton nach der Ansage abgespielt werden?
</li>

<li><b>Schedule</b><p>
AB soll nur zu bestimmten Zeiten aktiv sein.
xx:xx Uhr anschalten - xx:xx Uhr ausschalten
</li>

<li><b>Mailversand</b><p>
Wenn die Aufnahmen per eMail verschickt werden sollen, muss ein Mailaccount hinterlegt werden.
</li>
</ul>

EOF
 fi



 if [ "$HELP" = "dtmf" ];
 then
cat << EOF
<br>
<font size=4><b>DTMF-Commands</b></font><hr><p>

<ul>
<li><b>Admin-Pincode</b><p>
Wird beim laufendem AB Pincode + # eingegeben, gelangt man in das Administrationsmenü.<br>
Die Tastencodes 1# bis xxx# spielen die Nachrichten ab.<br>
Man kann auch intern die Tastencodes *#100# - *#109# verwenden, um in die Administration von Account 1 bis 10 zu gelangen.<br>
<i>Default: 1234</i>
</li>

<li><b>DTMF-Commands</b><p>
Hierüber kann man eigene (kurze) Skripts ausführen (z.B. WOL, Dienste neu starten, Anruf durchführen, etc.).<br>
Es können max. 50 Befehle hinterlegt werden (*1 - *50#).
</li>

<li><b>Callthrough</b><p>
Einen Callthrough kann man über **# durchführen (siehe auch <a href="dtmfbox.cgi?help=cbct">Callback & Callthrough</a>).
</li>
</ul>

EOF
 fi

 if [ "$HELP" = "cbct" ];
 then
cat << EOF
<br>
<font size=4><b>Callback & Callthrough</b></font><hr><p>

<ul>
<li><b>Callback</b><p>
Anrufen & Auflegen (Der Rückruf erfolgt unmittelbar nach dem Auflegen)
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
Der Callback soll auf die Rufnummer 022112345 reagieren. Die Nummer, auf die zurückgerufen werden soll, ist die 0160555555555. Als MSN (Account) soll 3322211 verwendet werden.<br>
<br>
Die Wahlregel könnte dann so aussehen:<br>
<pre>
022112345/0160555555555/3322211
</pre>
<p>
Bei der Trigger-Nr. kann man auch Regular Expressions verwenden:
<pre>
^.*12345$/0160555555555/3322211
</pre>
</li>

<li><b>Pincode</b><p>
Der Pincode, welcher vorher abgefragt werden soll. Falls kein Pin hinterlegt, wird die Passwortabfrage übersprungen.
</li>
<p>

<li><b>Menüsteuerung (Callback / Callthrough)</b><p>
    <ul>
    <li><b>(1) Administration</b><br>
    **# = Callthrough Menü wählen<p>

	<li><b>(2) Pincode eingeben + # (falls hinterlegt)</b><br>
    *# = zurück zur Administration<p>

	<li><b>(3) Account wählen, über den (raus)-telefoniert werden soll</b><br> 
    1# bis 10# = Account<br>
    0# = Interne Verbindung<br>
    *# = zurück zur Administration<p>

	<li><b>(4) Nr. wählen</b><br>
    # = Auflegen<br>            
    *# = zurück zur Accountwahl<p>

    Falls man sich mal verwählt, einfach einen * (Stern) in der Nummer mitangeben.<br>
    </ul>
</li>


</ul>
EOF
fi

 if [ "$HELP" = "voip_capi" ];
 then
cat << EOF
<br>
<font size=4><b>VoIP- & CAPI-Einstellungen</b></font><hr><p>

<li><b>VoIP verwenden</b><p>
VoIP (SIP) an-/ausschalten
</li>

<li><b>UDP Server Port</b><p>
Der Port, welcher dem SIP Server zugewiesen werden soll (SIP-Messages).
</li>

<li><b>RTP/RTCP Start Port</b><p>
Start-Port und Anzahl der RTP/RTCP Verbindungen (Sprachübertragung).<br>
Für jede VoIP-Verbindung werden jeweils zwei Ports benötigt.
</li>

<li><b>Registrar-Modus</b><p>
Die dtmfbox als Registrar verwenden (SIP-Clients können sich an die dtmfbox anmelden).<br>
Die Anzahl der max. Clients die sich anmelden dürfen, werden rechts daneben eingetragen.
</li>

<li><b>Realm</b><p>
IP-Adresse der FB, bzw. Hostname
</li>

<li><b>Interface (optional)</b><p>
Wenn das falsche Interface gefunden wird, sollte hier die IP der Box eingetragen werden (bzw. dyndns-Adresse).
</li>

<li><b>STUN Server</b><p>
STUN Server (bei NAT Problemen)
</li>

<li><b>ICE verwenden</b><p>
Soll ICE (Interactive Connectivity Establishment) verwendet werden?<br>
Es muss ein STUN Server angegeben werden, um ICE zu verwenden!
</li>

<li><b>Re-Register Intervall</b><p>
Zeitintervall, wann eine Neuregistrierung beim SIP-Provider durchgeführt werden soll.
</li>

<li><b>Keep-Alive Intervall</b><p>
In welchen Abständen sollen Dummy-Messages an den Server geschickt werden, um die Verbindung aufrecht zu erhalten.
</li>

<li><b>VAD (silence detector)</b><p>
Sprachpausen Erkennung an-/ausschalten
</li>

<li><b>CAPI-Controller</b><p>
Der eingehende, ausgehende und interne Controller der CAPI-Schnittstelle (ISDN/Analog).
</li>


<li><b>Early B3</b><p>
Early B3 an-/ausschalten<br>
Es wird ein Wählton beim Verbindungsaufbau mit einem anderen Gesprächspartner abgespielt.<br>
Da dies ein Fake-Ringtone ist, bekommt man hier (noch) keine richtigen Providerinfos (z.B. "Kein Anschluss unter dieser Nummer" oder Besetzt-Zeichen)
</li>



</ul>

EOF
 fi
}

# ------------------------------------------------

cgi_begin "$package" "pkg_$package"
frm_begin "$package"
