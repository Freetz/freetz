#!/bin/sh

# Change to fullscreen under Freetz
cat << EOF
<script>
if(document.location.href.indexOf('pkgconf.cgi?') >= 0) {
	window.open('dtmfbox.cgi?page=help');
	document.location.href = '$MAIN_CGI&page=status';
}
</script>
EOF

[ "$HELPPAGE" = "" ] && HELPPAGE="vorwort";
MAIN_CGI="dtmfbox.cgi?pkg=dtmfbox"

#
# Basiseinstellungen
#
if [ "$HELPPAGE" = "basiseinstellungen" ]; then
echo '<a name="basiseinstellungen" href="#basiseinstellungen"></a>'
show_title "Basiseinstellungen"
cat << EOF
Unter <a href="$MAIN_CGI&page=dtmfbox_cfg" target="_new">Basiseinstellungen</a> wird die Datei <i>dtmfbox.cfg</i> bearbeitet.<br><br>
Diese stellt die Grundkonfiguration des Programms dar. Standardmäßig ist die Datei so eingerichtet, <br>
dass nur wenige Änderungen vorgenommen werden müssen, wie z.B. die Einrichtung von <a href="$MAIN_CGI&page=help&help=accounts">Accounts</a>.<br><br>

Der Aufbau ist in <font class='code'>[Bereiche]</font> unterteilt.<br><br>

Im Text-Editor werden Kommentare mit Doppel-Slashes gekennzeichnet (<font class='code'>// Kommentar</font>). Siehe auch <a href="$MAIN_CGI&page=help&help=webinterface">hier</a>.<br>
<br>
EOF
fi

#
# Vorwort
#
if [ "$HELPPAGE" = "vorwort" ]; then
echo '<a name="vorwort" href="#vorwort"></a>'
show_title "Vorwort"
cat << EOF
	Die dtmfbox ist eine Softswitch Applikation, welche folgende Features unterstützt:<br>
	<ul>
	<li>SIP und CAPI</li>
	<li>Registrar-Modus für die Anbindung von SIP-Clients (VoIP-Gateway)</li>
	<li>Soundkartenunterstützung / Telefonie über Headset, bzw. Null-Audio</li>
	<li>STUN und ICE</li>
	<li>VAD und Echo Canceller</li>
	<li>Mixer</li>
	<li>Diverse Codecs</li>
	<li>Bei Telefonie-Ereignissen kann ein Skript und/oder ein Plugin aufgerufen werden</li>
	<li>Telefonie-Befehle lassen sich über die Kommandozeile, per Skript oder über eine Funktion ausführen</li>
	</ul>
	Ohne Skripte und Plugins lässt sich die dtmfbox rein als CAPI-/SIP-Phone nutzen.
	Dabei wird der Rufaufbau entweder über den angebundenen SIP-Client ausgelöst (Registrar-Mode), bzw. manuell von der Konsole ausgeführt (<font class='code'>dtmfbox 0 -call ...</font>).
	<br><br>

	Mithife von Shell-Skripten und Plugins lässt sich jedoch der Funktionsumfang erweitern.<br>
	Es bietet sich die Möglichkeit, automatisierte Steuerungen durchzuführen, wie z.B.:<br>
	<ul>
	<li>ein Gespräch automatisch annehmen, aufzeichnen und eine Wave-Datei abspielen (Anrufbeantworter)
	<li>ein weiteres Gespräch aufbauen und mit dem bestehenden Gespräch "verbinden" (Callthrough)
	<li>nach dem Auflegen einer bestimmten Nummer, einen Rückruf veranlassen (Callback)
	<li>Benutzerdefinierte (Sprach-)Menüs (libmenu.plugin.so)
	<li>usw...
	</ul>
	Die <a href="$MAIN_CGI&page=help&help=ereignisse" target="_new">Telefonie-Ereignisse</a> werden als Parameter an die Skripte und Plugins übergeben.<br>
	Die <a href="$MAIN_CGI&page=help&help=befehle" target="_new">Telefonie-Befehle</a> lassen sich über die Kommandozeile oder über eine Funktion aufrufen.
	<br><br>

	Das Webinterface der dtmfbox besteht aus einem Plugin und mehreren Skripten:<br><br>
	<i>libmenu.plugin.so</i> dient dazu, eine komfortable Menüschnittstelle zu bieten, welche sich über die Datei <a href="$MAIN_CGI&page=menu_cfg" target="_new">menu.cfg</a> anpassen lässt.
	In dieser Konfiguration wird das <a href="$MAIN_CGI&page=help&help=menu_start" target="_new">Menü</a> festgelegt.
	Zudem lassen sich <a href="$MAIN_CGI&page=help&help=menu_action">Aktionen</a> (<a href="$MAIN_CGI&page=help&help=ereignisse">Ereignisse</a>) hinterlegen.
	<br><br>

	Im Standard gibt es folgende Funktionen:
	<ul>
		<li><b>Anrufbeantworter</b></li>
		    <i>Ansage/Endansage, Aufnahme-/Ansagemodus, Mailversand/FTP-Streaming, Schedule</i>
		</li><p></p>

		<li><b>Anrufbeantworter Fernabfrage und interne Abfrage</b><br>
		    <i>Aufnahmen Abspielen, Aufnahmen löschen, Ansagen aufnehmen, AB aktivieren/deaktivieren</i>
		</li><p></p>

		<li><b>DTMF-Befehle</b><br>
		    <i>Menü-Tasten mit Shellskripten belegen</i>
		</li><p></p>

		<li><b>Callback & Callthrough</b><br>
		    <i>Callback/Callthrough-Regeln per Regular Expression. Weiterleitung zum Callthrough-Menü...</i>
		</li><p></p>

		<li><b>Sonstiges</b><br>
		    <i>Fritz!Box Infos, Wettervorhersage (Podcast), Web-Radio, CheckMailD abfragen</i>
		</li>
	</ul>
	Das Menü ist hierarchisch aufgebaut (siehe <a href="$MAIN_CGI&page=help&help=menu_start" target="_new">hier</a>).
	<a href="$MAIN_CGI&page=menu_cfg" target="_new">Menü</a> und <a href="$MAIN_CGI&page=scripts" target="_new">Skripte</a> lassen sich nach belieben erweitern und bearbeiten.<br><br>

	Einstellungen werden bei der Standalone-Version in der <i>/var/flash/debug.cfg</i> gespeichert (komprimiert). <br>
	Bei der USB-Version wird nur ein Start-Skript in die <i>/var/flash/debug.cfg</i> geschrieben.<br>
	Bei der Apache-Installation werden die Daten unkomprimiert, unter <i>/usr/bin/dtmfbox-apache</i> abgelegt.<br><br>

	<b>License:</b>
<ul>
<pre class='code' style='width:550px'>
 dtmfbox Copyright (c) 2006-2009 Marco Zissen (maz@v3v.de)

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
</pre>
</ul>
EOF
fi


#
# Getting started...
#
if [ "$HELPPAGE" = "getting_started" ]; then
echo '<a name="getting_started" href="#getting_started"></a>'
show_title "Getting started..."
cat << EOF
<ul>
	<table border="0" width="300">
	<tr><td width="200">1.) <a href="$MAIN_CGI&page=help&help=accounts">Account(s) einrichten</a></td><td>(<a href="$MAIN_CGI&page=dtmfbox_cfg" target="_new">dtmfbox.cfg</a>)</tr>
	<tr><td width="200">2.) <a href="$MAIN_CGI&page=help&help=internes_menu">Interne Menüs zuweisen</a></td><td>(<a href="$MAIN_CGI&page=dtmfbox_cfg" target="_new">dtmfbox.cfg</a>)</tr>
	<tr><td width="200">3.) <a href="$MAIN_CGI&page=help&help=skripteinstellungen">Skripteinstellungen</a></td><td>(<a href="$MAIN_CGI&page=script_cfg" target="_new">script.cfg</a>)</tr>
	<tr><td width="200">4.) <a href="$MAIN_CGI&page=help&help=status">dtmfbox starten</a></td><td>(<a href="$MAIN_CGI&page=status" target="_new">Status</a>)</tr>
	</table>
</ul>
EOF
fi

#
# Status
#
if [ "$HELPPAGE" = "status" ]; then
echo '<a name="status" href="#status"></a>'
show_title "Status"
cat << EOF
Auf der <a href="$MAIN_CGI&page=status" target="_new">Statusseite</a> befindet sich der aktuelle Dienste-Status der dtmfbox.<br><br>
Hier kann die dtmfbox manuell gestartet und gestoppt werden.<br>
Zusätzlich kann die Programmausgabe mitgeloggt werden.<br><br>

Die Befehle für die Konsole sehen folgendermaßen aus:
<pre class='code'>
rc.dtmfbox start|stop|restart	# starten, stoppen, neu starten.
rc.dtmfbox foreground		# im Vordergrund starten, mit Skriptausgaben, für Tests.
rc.dtmfbox log			# geloggt starten, ohne Skriptausgaben.
</pre>

Ist die dtmfbox gestartet, werden alle Accounts (mit Registrierungsstatus), alle aktuellen Verbindungen und alle angemeldeten Clients angezeigt.
Falls Nachrichten auf den Anrufbeantworter vorhanden sein sollten, werden diese ebenfalls auf der Seite "<a href='$MAIN_CGI&page=status' target='_new'>Status</a>" angezeigt.
<br><br>

<i>Hinweis:</i><br>
echo-Ausgaben in Skripten erscheinen nicht im Log!<br>
Skriptausgaben werden angezeigt, wenn die dtmfbox im Vordergrund gestartet wird: <font class='code'>./rc.dtmfbox foreground</font>
EOF
fi


#
# Accounts einrichten
#
if [ "$HELPPAGE" = "accounts" ]; then
echo '<a name="accounts" href="#accounts"></a>'
show_title "Accounts einrichten"
cat << EOF
	Grundvorraussetzung ist das Einrichten von Accounts.<br><br>
	Unter <a href="$MAIN_CGI&page=dtmfbox_cfg" target="_new">Basiseinstellungen</a> können bis zu 10 Accounts eingerichtet werden.
	Die Bereiche fangen bei <font class='code'>[acc1]</font> an und hören bei  <font class='code'>[acc10]</font> auf.<br>
	Einzelne Accounts können mittels <font class='code'>'active='</font> aktiviert (<font class='code'>1</font>), bzw. deaktiviert (<font class='code'>0</font>) werden.
	<p>
	Es gibt vier Arten, Accounts einzurichten:
	<ul>
		<a name="m1" href="#m1"></a>
		<li><b>ISDN/Analog (über CAPI)</b><p></p>

		Bei ISDN ist dies die optimale Wahl. Bei Analog gibt es gewisse Einschränkungen (siehe unten).<br><br>

<i>Beispiel (ISDN):</i><br>
<pre class='code'>
[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=ISDN1				// Name (beliebig)
number=1234567				// Rufnummer (MSN ohne Vorwahl!)
type=capi				// Account-Typ (type=capi)
capi_controller_out=1			// Standardcontroller für ausgehende Verbindungen
</pre>

<i>Beispiel (Analog):</i><br>
<pre class='code'>
[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=1234567				// Name (Anschlussnummer ohne Vorwahl!)
number=unknown				// Rufnummer (unknown)
type=capi				// Account-Typ (type=capi)
capi_controller_out=4			// Standardcontroller für ausgehende Verbindungen
</pre>
		Bei Analog wie auch ISDN wird die Nummer immer OHNE VORWAHL angegeben!<br>
		Bei ISDN darf der <font class='code'>name=</font> beliebig sein und <font class='code'>number=</font> muss der MSN entsprechen.<br>
		Bei Analog muss <font class='code'>number=</font> auf <font class='code'>'unknown'</font> gestellt werden. Die Anschlussnummer wird unter <font class='code'>name=</font> festgelegt.<br>
		<font class='code'>capi_controller_out=</font> ist der Standardcontroller, der für ausgehende Verbindungen verwendet wird (ISDN=1, Analog=4).<br><br>

		Die Accounts stehen unter <a href="$MAIN_CGI&page=status" target="_new">Status</a> solange auf "Pending", bis ein Anruf eingeht, bzw. ein Anruf durchgeführt wird.<br><br>

		<i>Einschränkungen Analog:</i><br>
		Da der POTS-Anschluss der FritzBox nicht wie der S0-Bus arbeitet, werden nur eingehende Gespräche erkannt, aber keine Ausgehenden.<br>
		Dies bedeutet, dass man das Menü nicht intern, über eine Kurzwahl, erreichen kann. <br>
		Um dennoch das Menü abzuhören, können Analog-Telefone über SIP-Registrar angebunden werden:
		</li><p></p>

		<a name="m2" href="#m2"></a>
		<li><b>ISDN/Analog (über SIP-Registrar)</b><p></p>
		Analog/ISDN-Telefone können optional über SIP angemeldet werden.<br>
		Dazu muss der Registrar-Modus der dtmfbox aktiviert und die Anmeldedaten des Clients hinterlegt werden:<p></p>

<i>Beispiel (Analog):</i><br>
<pre class='code'>
[voip]
voip=1					// VoIP aktivieren!
voip_registrar=1			// Registrar-Modus an!
voip_max_clients=4			// Anzahl der Clients, die sich anmelden dürfen
voip_realm=fritz.box			// Realm für den Registrar
voip_udp_port=5061			// Port, für SIP
voip_rtp_start=4000			// Start-Port, für RTP/RTCP
<a href="$MAIN_CGI&page=help&help=basiseinstellungen">// ...			 		// siehe auch Basiseinstellungen</a>

[acc1]
active=1				// Analog-Account
name=1234567
number=unknown
type=capi
capi_controller_out=4
registrar_active=1			// Aktiviert die Anmeldung an die dtmfbox
registrar_user=1234567			// Username
registrar_pass=secret			// Passwort
</pre>

		Im AVM-WebIf wird nun ein Internettelefonie-Account angelegt.<br>
		In diesem Beispiel würde man als Registrar "127.0.0.1:5061" oder "fritz.box:5061" angeben mit dem Usernamen "1234567" und dem Passwort "secret".<br><br>
		Bei erfolgreicher Anmeldung wird der Client unter <a href="$MAIN_CGI&page=status" target="_new">Status</a> angezeigt.<br>
		</li><p></p>

		<a name="m3" href="#m3"></a>
		<li><b>VoIP (über CAPI)</b><p></p>
		Um die bereits registrierten Internettelefonie-Accounts des voipd zu verwenden, kann man diese ebenfalls über CAPI registrieren.<br>
		Hierbei ist wichtig, welche Position der Internettelefonie-Account in der Liste hat (AVM-WebIf).<p></p>

<i>Beispiel (1. Internettelefonie-Account):</i><br>
<pre class='code'>
[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=1234567				// Beliebiger Name
number=0#1234567			// 0# = Erster Account, 1234567=Internetrufnummer
type=capi				// type=capi
capi_controller_out=5			// Standardcontroller für ausgehende Verbindungen
</pre>

<i>Beispiel (4. Internettelefonie-Account):</i><br>
<pre class='code'>
[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=7654321				// Beliebiger Name
number=3#7654321			// 3# = Vierter Account, 7654321=Internetrufnummer
type=capi				// type=capi
capi_controller_out=5			// Standardcontroller für ausgehende Verbindungen
</pre>
		</li><p></p>

		<a name="m4" href="#m4"></a>
		<li><b>VoIP (über SIP)</b><p></p>
		Um SIP-Accounts direkt über die dtmfbox zu registrieren, müssen die Provider-Daten des Registrars eingetragen werden<p></p>

<i>Beispiel (SIP-Account):</i><br>
<pre class='code'>
[voip]
<a href="$MAIN_CGI&page=help&help=basiseinstellungen">// ...	 				// siehe Basiseinstellungen</a>

[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=SIP Account			// Beliebiger Name (wird als Display-Name verwendet)
number=1234567  			// Internetrufnummer
type=voip				// type=voip

voip_registrar=sip.registrar.de	// Registrar-Server
voip_realm=registrar.de		// SIP-Realm (* für automatische Suche)
voip_user=MeinUsername			// Username
voip_pass=MeinPasswort			// Passwort
voip_do_not_register=0			// 1=Keine Registrierung, 0=Registrieren
voip_id=				// Optional: SIP-ID (MeinUsername@sip.registrar.de)
voip_proxy=				// Optional: Proxy
voip_contact=				// Optional: SIP-Contact
</pre>

		Manchmal wird für die Registrierung ein STUN-Server benötigt. Bei NAT-Problemen ist manchmal auch die Aktivierung von ICE nötig (z.B. One-Way Audio).
		Näheres siehe auch <a href="$MAIN_CGI&page=help&help=basiseinstellungen">Basiseinstellungen</a>.<br><br>
		Provider-Beispiele:<p></p>

<i>Beispiel (1&1):</i><br>
<pre class='code'>
[voip]
<a href="$MAIN_CGI&page=help&help=basiseinstellungen">// ...	 				// siehe Basiseinstellungen</a>
voip_stun=stun.1und1.de
voip_stun_port=3478
voip_ice=1

[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=49123456789			// Beliebiger Name (wird als Display-Name verwendet)
number=49123456789  			// Internetrufnummer
type=voip				// type=voip

voip_registrar=sip.1und1.de		// Registrar-Server (oder IP direkt: 212.227.15.197)
voip_realm=1und1.de			// SIP-Realm (* für automatische Suche)
voip_user=49123456789			// Username
voip_pass=MeinPasswort			// Passwort
voip_do_not_register=0			// 1=Keine Registrierung, 0=Registrieren
voip_id=49123456789@1und1.de		// Optional: SIP-ID (MeinUsername@sip.registrar.de)
voip_proxy=				// Optional: Proxy
voip_contact=				// Optional: SIP-Contact
</pre>

<i>Beispiel (Sipgate):</i><br>
<pre class='code'>
[voip]
<a href="$MAIN_CGI&page=help&help=basiseinstellungen">// ...	 				// siehe Basiseinstellungen</a>
voip_stun=stun.1und1.de
voip_stun_port=3478
voip_ice=1

[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=49123456789			// Beliebiger Name (wird als Display-Name verwendet)
number=49123456789  			// Internetrufnummer
type=voip				// type=voip

voip_registrar=sipgate.de		// Registrar-Server
voip_realm=sipgate.de			// SIP-Realm (* für automatische Suche)
voip_user=55112233			// Username
voip_pass=MeinPasswort			// Passwort
voip_do_not_register=0			// 1=Keine Registrierung, 0=Registrieren
voip_id=55112233@sipgate.de		// Optional: SIP-ID (MeinUsername@sip.registrar.de)
voip_proxy=				// Optional: Proxy
voip_contact=				// Optional: SIP-Contact
</pre>
		</li>
	</ul>
EOF
fi

#
# Kurzwahlen einrichten
#
if [ "$HELPPAGE" = "internes_menu" ]; then
echo '<a name="internes_menu" href="#internes_menu"></a>'
show_title "Kurzwahlen einrichten"
cat << EOF
Das Menü kann über Kurzwahlen erreicht werden.<br>
Dies gilt für ISDN-Accounts, wie auch Accounts, welche über den Registrar-Modus angebunden sind (SIP-Clients angemeldet an dtmfbox).<br><br>

Damit das Telefon auf die Kurzwahl reagiert, müssen zwei Einträge unter <font class='code'>[accX]</font> eingefügt werden:<br><br>

<i>Beispiel:</i><br>
<pre class='code'>
[acc1]
<a href="$MAIN_CGI&page=help&help=accounts">// ...	 					// siehe Accounts</a>
menu_keycode=*800				// Kurzwahl (hier *800)
menu_entry=menu:main				// Menü-Einstiegspunkt (menu:main ist das Hauptmenü)
</pre>

Von Außerhalb kann das Menü über den Anrufbeantworter, bzw. über Callback/Callthrough erreicht werden.<br><br>

<i>Hinweis:</i><p>
Es kann vorkommen, dass das Telefon nicht auf die Kurzwahl reagiert. Dies kann mit verschiedenen Dingen zusammenhängen (FW-Version, Telefone, usw.).<p>

Man sollte zunächst prüfen, ob überhaupt DTMF-Zeichen empfangen werden, wenn gewählt wird. Dies kann mithilfe des Logs festgestellt werden.<br>
Wenn abgenommen wird (Log: Hook up), aber kein Ton zu hören ist oder die Navigation per DTMF nicht möglich sein sollte, liegt das oft an dem Format der Kurzwahl.<br>
<br>
Man sollte daher folgende Kurzwahlen durchprobieren:
<ul>
<li><font class='code'>800</font></li>
<li><font class='code'>*800</font></li>
<li><font class='code'>**800</font></li>
<li><font class='code'>**##800</font></li>
</ul>
800 ist nur ein Beispiel. Testweise sollte man auch andere Nummern verwenden.<p>

Falls immer noch kein Ton zu hören ist, bzw. die Navigation nicht funktioniert, kann man im AVM-WebIf unter Telefoniegeräte\Festnetz eine zusätzliche Rufnummer hinterlegen (in dem Fall die gewünsche Kurzwahl, z.B. 800). Danach nochmal die oberen Kombinationen ausprobieren.<p>

Falls dieser Versuch ebenfalls scheitert, bleibt noch die Möglichkeit, die ISDN-Telefone per SIP-Registrar anzubinden (siehe auch <a href='http://fritz.box:6767/cgi-bin/dtmfbox.cgi?pkg=dtmfbox&page=help&help=accounts'>Accounts einrichten</a>).<br>
Die Kurzwahl darf in dem Fall aber kein # oder * enthalten! Beim ersten Internet-Telefonieaccount würde man <font class='code'>*121#800</a> wählen.
EOF

fi

#
# Das Menü
#
if [ "$HELPPAGE" = "menu_start" ]; then
show_title "Das Menü"
cat << EOF
In der dtmfbox-Standardkonfiguration ist ein vorgefertigtes Menü integriert, welches bei Bedarf geändert werden kann.<br>
Das Menü kann über drei Wege erreicht werden:
<ul>
<li><b>Intern über die  Kurzwahl des Accounts</b><br>
Dies gilt für ISDN-Accounts, wie auch Accounts, welche über den Registrar-Modus angebunden sind (SIP-Clients angemeldet an dtmfbox). Das Einstiegsmenü kann unter <a href='$MAIN_CGI&page=dtmfbox_cfg' target='_new'>Basiseinstellungen</a> geändert werden (Standardmäßig <font class='code'>[menu:main]</font>)</li><br>

<li><b>Extern über den Anrufbeantworter</b><br>
Sobald der Anrufbeantworter abhebt, wird der AB-Pin eingegeben. Das Einstiegsmenü ist <font class='code'>[menu:main]</font></li><br>

<li><b>Extern über Callback/Callthrough.</b><br>
Das Einstiegsmenü ist <font class='code'>[menu:callthrough_pin]</font></li><br>
</ul>

<b>Menüstruktur:</b><br>
<pre class='code'>
Hauptmenü
|
|- 1 = Anrufbeantworter
|  |
|  |- X# = Nachricht X abhören
|  |- 0# = Einstellungen
|  |  |
|  |  |- 1 = Aktivieren / Deaktivieren
|  |  |- 2 = Aufnahmen löschen
|  |  |  |
|  |  |  |- 1 = Alle Aufnahmen löschen
|  |  |  |- * = Zurück
|  |  |
|  |  |- * = Zurück
|  |
|  |- * = Zurück
|
|- 2 = DTMF-Befehle
|  |
|  |- X = Eigene Befehle, Shellskripte, etc.
|  |- * = Zurück
|
|- 3 = Callthrough
|  |
|  |- 1234# = Pineingabe (Pin kann im Menü bearbeitet werden)
|  |     |
|  |     |- X# = Account 1-10 oder 0# für die Wahl über den internen S0 Bus
|  |        |
|  |        |- NUMMER#   = Nummer eingeben und wählen (#)
|  |        |- NUMMER*#  = Nummer eingeben und korrigieren (verwählt)
|  |        |- #         = Auflegen
|  |        |- *         = Zurück
|  |
|  |- * = Zurück
|
|- 4 = Sonstiges
   |
   |- 1 = Fritz!Box
   |  |
   |  |- 1 = IP-Adresse
   |  |- 2 = Letzter Reboot
   |  |- 3 = Uhrzeit
   |  |- * = Zurück
   |
   |- 2 = Wettervorhersage
   |  |
   |  |- 1 = Wetter-Podcast abspielen
   |  |- * = Zurück
   |
   |- 3 = Checkmaild
   |  |
   |  |- X = Mailanzahl von Checkmail-Account X (1-3) abfragen
   |  |- * = Zurück
   |
   |- 4 = Radio
      |
      |- X = Radiostream 1-9
      |- * = Zurück
</pre>

EOF
fi

#
# Menü bearbeiten
#
if [ "$HELPPAGE" = "menu" ]; then
show_title "Menü bearbeiten"
cat << EOF
Das Menü kann individuell bearbeitet werden.<br>
Es ist ebenfalls in <font class='code'>[Bereiche]</font> unterteilt, jedoch werden diese anders interpretiert.<br><br>

Es gibt vier Bereiche:
<ul>
	<li><a href="$MAIN_CGI&page=help&help=menu_menu"><b>[menu: ... ]</b></a><br>
	Stellt ein Menü dar.<br>
	Es können DTMF-Zeichen hinterlegt werden, welche ein Menü <font class='code'>[menu:]</font> , ein Skript <font class='code'>[script:]</font> oder eine Library-Funktion <font class='code'>[lib:] aufrufen.</font>
	</li><p></p>

	<li><a href="$MAIN_CGI&page=help&help=menu_script"><b>[script: ... ]</b></a><br>
	Führt ein Skript aus, wenn der Bereich aufgerufen wird.<br>
	Es kann ein Skript hinterlegt werden, welches ausgeführt werden soll (inkl. Parameter).
	</li><p></p>

	<li><a href="$MAIN_CGI&page=help&help=menu_lib"><b>[lib: ... ]</b></a><br>
	Führt eine Funktion in einer Library aus, wenn der Bereich aufgerufen wird.<br>
	Es kann eine Library und ein Funktionsname hinterlegt werden (inkl. Parameter).
	</li><p></p>

	<li><a href="$MAIN_CGI&page=help&help=menu_action"><b>[action: ... ]</b></a><br>
	Führt einen <font class='code'>[script:]</font> oder <font class='code'>[lib:]</font> Bereich aus, bei bestimmten Ereignissen.<br>
	Es werden die Ereignisse und ein <font class='code'>[script:]</font> oder <font class='code'>[lib:]</font> Bereich angegeben.
	</li><p></p>
</ul>

Alle Menü-, Skript- und Library-Bereiche müssen einen eindeutigen Namen besitzen.<br>
Der Name wird nach dem Doppelpunkt gesetzt. Z.B. <font class='code'>[menu:my_menu1], [script:my_script1]</font>, usw...<br><br>

Es können beim Aufruf der Bereiche auch Parameter übergeben werden (bis zu 32):
<pre class='code'>
[menu:main]
say=Hauptmenue
1=script:myscript("Hallo", "Test")		     // "Hallo" und "Test" an Skript übergeben
2=menu:zweites_menu("Hallo2")			     // "Hallo2" an Menü übergeben

[menu:zweites_menu]
say=Zweites Menue
1=script:myscript("%\$1%", "Test2")		     // %\$1%="Hallo2" u. "Test2" an Skript übergeben
*=menu:main

[script:myscript]				     // 1. und 2. Argument an Skript übergeben
cmd=/var/script/myscript.sh(/var/script/myscript.sh, "%\$1%", "%\$2%")
</pre>
Die Parameter stehen dann als Argumente innerhalb des Bereiches zur Verfügung (von <font class='code'>%\$1%</font> bis <font class='code'>%\$32%</font>)<br><br>

<a href='$MAIN_CGI&page=help&help=ereignisse'>Ereignisse</a> können ebenfalls als Parameter übergeben werden.
EOF
fi

#
# [menu: ... ]
#
if [ "$HELPPAGE" = "menu_menu" ];
then
echo '<a name="menu_menu" href="#menu_menu"></a>'
show_title "[menu: ... ]"
cat << EOF
Ein <font class='code'>[menu:XYZ]</font> stellt einen Menü-Bereich dar. In dem Fall mit dem eindeutigen Namen XYZ.<br><br>

Ein Menü kann beliebig lang sein. Es können einzelne DTMF-Zeichen mit Untermenüs, Skripten und Library-Funktionen verknüpft werden.
Ganze DTMF-Zeichenfolgen sind ebenfalls möglich.<br><br>

<i>Beispiel (einzelne DTMF-Zeichen):</i>
<pre class='code'>
[menu:main]
say=1 Erstes Menue, 2 Zweites Menue
1=menu:menu_1
2=menu:menu_2

[menu:menu_1]
say=Menu 1. Zurueck mit *
*=menu:main

[menu:menu_2]
say=Menu 2. Zurueck mit *
*=menu:main
</pre>

<i>Beispiel (mehrere DTMF-Zeichen):</i>
<pre class='code'>
[menu:main]
say=101# Erstes Menue, 102# Zweites Menue
101#=menu:menu_1
102#=menu:menu_2

[menu:menu_1]
say=Menu 1. Zurueck mit *
*=menu:main

[menu:menu_2]
say=Menu 2. Zurueck mit *
*=menu:main
</pre>

Wird <font class='code'>say=</font> mit angegeben, wird das <font class='code'>text2speech=</font> Skript ausgeführt, welches unter den <a href="$MAIN_CGI&page=dtmfbox_cfg" target="_new">Basiseinstellungen</a> hinterlegt ist. <br>
Der angegebende Text wird auf das Telefon ausgegeben, solange <a href="http://espeak.sourceforge.net/" target="_new">eSpeak</a> verwendet wird (<a href="$MAIN_CGI&page=script_cfg" target="_new">Skripteinstellungen > <font class='code'>ESPEAK_INSTALLED=X</font></a>).
EOF
fi

#
# [script: ... ]
#
if [ "$HELPPAGE" = "menu_script" ];
then
echo '<a name="menu_script" href="#menu_script"></a>'
show_title "[script: ... ]"
cat << EOF
Ein <font class='code'>[script:XYZ]</font> stellt einen Skript-Bereich dar. In dem Fall mit dem eindeutigen Namen XYZ.<br><br>
Skripte können von Menüs <font class='code'>[menu:]</font> und Aktionen <font class='code'>[action:]</font> aufgerufen werden.
<br><br>
<i>Beispiel 1:</i>
<pre class='code'>
[menu:main]
say=1 Erste Skript Funktion, 2 Zweite Skript Funktion.
1=script:myscript(1)		// 1 übergeben
2=script:myscript(2)		// 2 übergeben

[script:myscript]
say=Skript %\$1% ausführen	// say "Skript X ausführen"
cmd=/var/dtmfbox/script/myscript1.sh(/var/dtmfbox/script/myscript1.sh, "%\$1%", "%src_id%")
</pre>
In dem obigen Beispiel wird zweimal das selbe Skript aufgerufen, jedoch mit unterschiedlichen Parametern (1 und 2). <br>
Zusätzlich wird der Platzhalter <font class='code'>"%src_id%"</font> an das Skript <font class='code'>"myscript1.sh"</font> übergeben.<br>
Im Skript stehen die Parameter dann als Argumente zur Verfügung (\$1="1" oder "2" und \$2="%src_id%").<br><br>

Auch hier kann <font class='code'>say=</font> angegeben werden, um einen Text auszugeben.<br><br>

<i>Beispiel 2 (selbes Skript wie oben, nur dynamisch):</i>
<pre class='code'>
[menu:main]
say=Skript-Funktion aufrufen
#=script:myscript(%dtmf%)	// DTMF-Zeichen übergeben

[script:myscript]
say=Skript %\$1% ausführen	// say "Skript X ausführen"
cmd=/var/dtmfbox/script/myscript1.sh(/var/dtmfbox/script/myscript1.sh, "%\$1%", "%src_id%")
</pre>
In dem obigen Beispiel wird ebenfalls das Skript aufgerufen, jedoch etwas dynamischer.<br>
Anstelle einzelne Skriptaufrufe für bestimmte Tasten festzulegen, wird beim Drücken der #-Taste der ganze DTMF-Buffer an das Skript übergeben.
Solange # nicht eingegeben wurde, werden die DTMF-Zeichen "gesammelt".<br>
Wird z.B. <font class='code'>100#</font> eingegeben, so steht in <font class='code'>%dtmf%</font> ebenfalls <font class='code'>"100#"</font>. In <font class='code'>%data%</font> steht immer das letzte Zeichen, welches in dem Fall <font class='code'>"#"</font> wäre.
<br><br>
In <font class='code'>cmd=</font> wird das eigentliche Skript angegeben. Der Aufruf ist wie bei der Funktion 'execl' unter C.<br>
Die Skriptdatei wird vor der Klammer und als erster Parameter angegeben.
EOF
fi

#
# [lib: ... ]
#
if [ "$HELPPAGE" = "menu_lib" ];
then
echo '<a name="menu_lib" href="#menu_lib"></a>'
show_title "[lib: ... ]"
cat << EOF
Ein <font class='code'>[lib:XYZ]</font> stellt einen Library-Bereich dar. In dem Fall mit dem eindeutigen Namen XYZ.<br><br>

Libraries können von Menüs <font class='code'>[menu:]</font> und Aktionen <font class='code'>[action:]</font> aufgerufen werden.<br>
Hierbei wird gezielt eine Funktion in einer Library aufgerufen. Die Libraries müssen nicht zwingend als Plugin eingebunden werden.<br><br>

<i>Beispiel:</i>
<pre class='code'>
[menu:main]
1=lib:speak("Hallo 1")
2=lib:speak("Hallo 2")
3=lib:speak("Hallo 3")

[lib:speak]
library=/var/dtmfbox/menu.plugin.so
function=speak(%src_id%,"%\$1%")
</pre>
Es können char*-und integer-Datentypen übergeben werden. Integer-Werte werden ohne Anführungsstriche angegeben.<br>
In dem obigen Beispiel wird die Funktion "speak()" in der Library menu.plugin.so aufgerufen. Der erste Parameter ist ein Integer, der Zweite ein char*.
EOF

fi

#
# [action: ... ]
#
if [ "$HELPPAGE" = "menu_action" ];
then
echo '<a name="menu_action" href="#menu_action"></a>'
show_title "[action: ... ]"
cat << EOF
Ein <font class='code'>[action:XYZ]</font> stellt eine Aktion dar, die bei bestimmten Ereignissen ausgelöst wird. In dem Fall mit dem eindeutigen Namen XYZ.<br><br>
Stimmen die angegebenen Ereignisse der Aktion überein, wird ein Skript oder eine Library aufgerufen. <br>
Im Gegensatz zu den anderen Bereichen, wird eine Aktion nicht von Menüs verwendet.<br><br>

<i>Beispiel:</i>
<pre class='code'>
[action:action_1]
event=CONNECT
//type=
direction=INCOMING
//src_id=
//dst_id=
//src_no=
dst_no=0049301234567
//data=
action=script:action_hookup

[script:action_hookup]
cmd=/var/action_hookup.sh(/var/action_hookup.sh, "%event%", "%type%", "%direction%", "%src_id%", "%dst_id%")
</pre>
Wenn:<br>
<font class='code'>%event%="CONNECT"</font> und <font class='code'>%direction%="INCOMING"</font> und <font class='code'>%dst_no%="0049301234567"</font>, <br>
Dann:<br>
<font class='code'>"action_hookup.sh"</font> ausführen (und Platzhalter übergeben).<br><br>
Innerhalb des Skriptes könne man z.B. die Verbindung annehmen (<font class='code'>\$DTMFBOX \$4 -hook up</font>).
<p></p>
<i>Hinweis:</i><br>
Bei mehrere Aktionen werden diese nacheinander ausgeführt (nach Namen sortiert).<br>
Eine Erläuterung zu den Ereignissen befindet sich <a href="$MAIN_CGI&page=help&help=ereignisse">hier</a>. Eine Erläuterung zu den Befehlen, <a href="$MAIN_CGI&page=help&help=befehle">hier</a>.
EOF
fi


#
# Skripteinstellungen
#
if [ "$HELPPAGE" = "skripteinstellungen" ];
then
echo '<a name="skripteinstellungen" href="#skripteinstellungen"></a>'
show_title "Skripteinstellungen"

cat << EOF
Unter <a href='$MAIN_CGI&page=script_cfg' target='_new'>Skripteinstellungen</a> werden die Einstellungen zu den Skripten vorgenommen.<br><br>

Alle Skripte binden diese Datei ein, wie auch das Webinterface, um Einstellungen am Text-Editor vorzunehmen zu können (Zeilen/Wrap).<br>
<br>
<ul>
	<li><b>Autostart</b><p>
	Gibt an, ob die dtmfbox beim Booten automatisch gestartet werden soll.</li><br>

	<li><b>Anrufbeantworter</b<p>
	Die Einstellungen für den Anrufbeantworter. Diese gelten für alle Accounts gleichermaßen.<br>
	Um accountspezifische Einstellungen zu hinterlegen, muss man im <a href="$MAIN_CGI?pkg=dtmfbox&page=script_cfg&direct_edit=1" target="_new">Text-Editor</a> die jeweiligen Einträge hinzufügen, mit dem Präfix <font class='code'>ACCX_</font> (X=Account ID). Globale Einstellungen fangen mit dem Präfix <font class='code'>GLOBAL_</font> an.<br>
	Um z.B. die Ansage von Account 5 zu ändern, folgende Zeile hinzufügen:<br>
<pre class='code'><font class='code'>ACC5_AM_ANNOUNCEMENT_START=/var/dtmfbox/play/ansage.wav  # Ansage für Account Nr. 5</font></pre>
	Als Ansage und Endansage kann man auch eine URL angeben, wie z.B. http://www.url.de/ansage.wav oder ftp://www.url.de/ansage.wav.<br>
	Wichtig ist, dass die PCM-Wave vom Format 8000hz, 16bit, Mono ist.<br>
	<br>
	Aufnahmen können per eMail verschickt oder auf einen FTP-Server abgelegt werden.<br>
	Beim eMail-Versand werden die Aufnahme als Wave-Datei versendet. Beim FTP-Streaming werden PCM-Dateien ohne Wave-Header geschrieben, welche ebenfalls über das AB-Menü abgehört werden können (RAW 8000hz, 16bit, Mono).
	</li><br>

	<li><b>Callthrough</b><p>
	Callthrough Regeln bestehen aus max. zwei Teilen, welche durch Schrägstriche getrennt werden:<br>
	<pre class='code'><font class='code'>Trigger-Nr./[Trigger-Accout]</font></pre>
	Die Trigger-Nr. muss angegeben werden. Sie ist die Nummer, die den Callthrough auslösen soll. Als Trigger-Nummer kann man eine Regular-Expression verwenden, um z.B. beliebigen Nummern den Zugang zum Callthrough zu ermöglichen.<br>
	Der Trigger-Account ist optional. Dies kann die Account-ID oder die Nummer des Accounts sein, welcher auf Callthroughs reagieren soll.<br>
	Wenn kein Trigger-Account angegeben wird, ist die Callthrough-Regel für alle Accounts aktiv.<br>
	<br>
	<i>Beispiel:</i><br>
	Account 1 soll bei einem Anruf der Nummer 004922112345 das Gespräch annehmen und an das Callthrough Menü weiterleiten:<br>
<pre class='code'>
004922112345/1          # Mit Angabe der Account-ID
004922112345/322423     # Mit Angabe der Account-Nummer
004922112345            # Ohne Angabe der Account-ID. Callthrough ist für alle Accounts aktiv.
.*2112345               # Callthrough mithilfe von Regular Expressions
</pre>
	<i>Hinweis:</i><br>
	<ul>
	<li>Bei ISDN ist es ratsam, unter den <a href='$MAIN_CGI?pkg=dtmfbox&page=dtmfbox_cfg' target='_new'>Basiseinstellungen</a> die Landes und Ortsvorwahl zu hinterlegen.
	<li>Es lassen sich beliebig viele Callthrough-Regeln über den <a href='$MAIN_CGI?pkg=dtmfbox&page=script_cfg&direct_edit=1' target="_new">Text-Editor</a> hinzufügen.
	<li>Die Callthrough-Regeln werden nacheinander abgearbeitet. Sobald eine leere Callthrough-Regel gefunden wird, bricht das Skript die weitere Prüfung ab.
	</ul>
	</li>

	<li><b>Callback</b><p>
	Callback Regeln bestehen aus zwei bis fünf Teilen, welche ebenfalls durch Schrägstriche getrennt werden:<br>
	<pre class='code'><font class='code'>Trigger-Nr./Rückruf-Nr./[Trigger-Account]/[Rückruf-Account]/[CAPI-Controller]</font></pre>
	Die Trigger- und Rückruf-Nr. muss angegeben werden. Die Trigger-Nr. ist die Nummer, welche den Callback auslösen soll. Rückruf-Nr. ist die Nummer, auf welche nach dem Auflegen zurückgerufen werden soll.<br>
	Optional können noch Trigger- und Rückruf-Account und ein CAPI Controller angegeben werden. Trigger-Account ist, wie beim Callthrough auch, die Einschränkung des Callbacks auf einen bestimmten Account.<br>
	Rückruf-Account ist der Account, welcher den Rückruf durchführen soll. Hier kann die Account-ID, aber auch die Nummer angegeben werden. Der CAPI-Controller bestimmt den ausgehenden Controller für den Callback und sollte bei VoIP-Accounts nicht angegeben werden.<br>
	<br>
	<i>Beispiel:</i><br>
	Der Callback soll auf die Rufnummer 004922112345 reagieren. Die Nummer, auf die zurückgerufen werden soll, ist die 0160555555555. Als MSN soll 3322211 verwendet werden (Account 1).
<pre class='code'>
004922112345/0160555555555/3322211      # Es wird hier die Nummer direkt angegeben.
004922112345/0160555555555/1            # Es wird hier die Nummer als ID übergeben.
004922112345/0160555555555              # Ohne Accountangabe. Callback für alle Accounts aktiv.
.*22112345/0160555555555                # Rückruf mithilfe von RegEx.
\(.*22112345\)/\1                       # Rückruf mithilfe von RegEx auf Trigger-Nr.
                                        # Trigger-Nr wird als Rückrufnummer verwendet. Nicht 0160555555555
</pre>
	<i>Hinweis:</i><br>
	<ul>
	<li>Bei ISDN ist es ratsam, unter den <a href='$MAIN_CGI?pkg=dtmfbox&page=dtmfbox_cfg' target='_new'>Basiseinstellungen</a> die Landes und Ortsvorwahl zu hinterlegen.
	<li>Es lassen sich beliebig viele Callback-Regeln über den <a href='$MAIN_CGI?pkg=dtmfbox&page=script_cfg&direct_edit=1' target="_new">Text-Editor</a> hinzufügen.
	<li>Die Callback-Regeln werden nacheinander abgearbeitet. Sobald eine leere Callback-Regel gefunden wird, bricht das Skript die weitere Prüfung ab.
	</ul>
	</li>

	<li><b>Webradio</b><p>
	Das Webradio kann man im Menü unter "(4) Sonstiges -> (4) Radio" erreichen. Vorraussetzung für das Abspielen von MP3-Streams ist das Programm 'madplay' (siehe auch: "Programme & Pfade").<br><br>
	Es können bis zu neun MP3-Streams hinterlegt werden (URLs). Durch eine entsprechende <a href='$MAIN_CGI?pkg=dtmfbox&page=menu_cfg' target='_new'>Menüänderung</a> lassen sich aber mehr Streams einfügen.<br>
	<br>
	<i>Beispiel:</i><br>

<pre class='code'>[menu:misc_radio]
say=Radio
1#=script:misc_radio(1)
...
50#=script:misc_radio(50)</pre>
oder:
<pre class='code'>[menu:misc_radio]
say=Radio
01=script:misc_radio(1)
...
50=script:misc_radio(50)</pre>
	</li><br>

	<li><b>Rückwärtssuche</b><p>
	Die Rückwärtssuche ermöglicht das Anzeigen von Name und Adresse auf dem ISDN-Telefon als Display-Message.<br>
	Den Accounts wird dabei eine Pseudo-MSN zugeordnet. Im Telefon wird die original Empfangs-MSN durch die Pseudo-MSN ersetzt. Die Sende-MSN bleibt unverändert!<p>

	<i>Hinweise:</i>
	<ul>
		<li>Die Rückwärtssuche funktioniert nur mit Telefonen, die am internen S0-Bus angeschlossen sind.<br>Fon1-3 und das interne DECT der FB werden nicht unterstützt!</li>
		<li>Das Skript <i>action_revers.sh</i> ruft zunächst die Funktion <i>revers_lookup1()</i> auf, welche als benutzerdefinierte Funktion dient. Hier kann man selbst Telefonnummern hinterlegen und Namen/Adresse ausgeben.
		Wird kein Eintrag ausgegeben, so wird die Funktion <i>revers_lookup2()</i> aufgerufen, welche eine Rückwärtssuche über "dasoertliche.de" durchführt.</li>
	</ul>
	</li><br>

	<li><b>Anti-Callcenter</b><p>
	Das Anti-Callcenter Skript dient dazu, unbekannte Anrufer direkt anzunehmen und zur Rufnummerneingabe aufzufordern.<p>
	Jedem Account kann eine Weiterleitungs-Rufnummer hinterlegt werden:<br>
	Bei ISDN ist es die MSN (bei aktiver Rückwärtssuche, die Pseudo-MSN).<br>
	Bei Analog und VoIP kann eine SIP-Adresse angegeben werden, wie z.B. 12345@fritz.box (siehe auch <a href='$MAIN_CGI&page=help&help=accounts'>Accounts einrichten /  SIP-Registrar</a>).<br><br>
	Es wird das Skript <i>action_anticallcenter.sh</i> aufgerufen.<p>

	<i>Hinweis:</i><br>
	Analog-Telefone müssen nicht unbedingt per SIP angebunden werden. Es reicht aus, im AVM-Webif einen Internet-Telefonieaccount anzulegen und einem FON-Anschluss zuzuordnen.
	Die Einstellungen des Internet-Telefonieaccount könnten folgendermaßen aussehen:<br>
	<ul>
	Internetrufnummer: 9000<br>
	Benutzername: 9000<br>
	Passwort: 9000<br>
	Registrar: localhost<br>
	Rufnummernformat anpassen: (alle Haken rausnehmen)<br>
	</ul>
	Der angelegte Telefonieaccount wird anschließend dem FON-Anschluss als zusätzliche Empfangsrufnummer zugeordnet.<br><br>
	Im dtmfbox-Webif wird die Weiterleitung <font class='code'>9000@fritz.box:5060</font> oder <font class='code'>9000@192.168.178.1</font> hinterlegt. Der jeweilige FON-Anschluss lässt sich über diese SIP-Uri direkt ansprechen.<br>
	</li><br>

	<li><b>Text2Speech (eSpeak)</b><p>
	Hier können die Einstellungen zu eSpeak verändert werden.<br>
	Es gibt drei Modis:
	<ul>
		<li><b>Installiert</b><br>
		eSpeak ist installiert. Entweder auf USB oder im Flash (Einstellungen zur Pfadangabe unten beachten!)</li><br>

		<li><b>Webstream</b><br>
		eSpeak über Webstream abrufen. Eine Installation von eSpeak ist nicht nötig.</li><br>

		<li><b>Beep</b><br>
		eSpeak deaktivieren. Nur Beep.</li>
	</ul>
	<i>Hinweis:</i><br>
	Der Typ: f5 und m5 (mbrola) ist nur als Webstream verfügbar.<br>
	</li><br>

	<li><b>Programme & Pfadangaben</b><p>
        Bei der USB-Version finden sich espeak, madplay usw. unter <font class='code'>/var/dtmfbox/extras</font>, sodass dieser Pfad hier voreingestellt ist.<br>
	Bei Freetz liegen die Programme an anderen Orten: <br>
	<ul>
		<li>eSpeak: <font class='code'>/usr/bin</font>
		<li>madplay: <font class='code'>/usr/bin</font>
		<li>checkmaild: <font class='code'>/mod/etc</font>
	</ul>
	</li><br>

	<li><b>Webinterface</b><p>
	Das Speicherverhalten kann auf "Diff + Patch + GZip" oder nur "GZip" eingestellt werden. Erstere Methode spart etwas Flash-Speicher, falls die dtmfbox im RAM installiert wurde.<br>
	</li><br>
</ul>
EOF
fi

#
# Skripte bearbeiten
#
if [ "$HELPPAGE" = "skripte_bearbeiten" ];
then
echo '<a name="skripte_bearbeiten" href="#skripte_bearbeiten"></a>'
show_title "Skripte bearbeiten"

cat << EOF
Skripte lassen unter <a href='$MAIN_CGI&page=scripts'>Skripte bearbeiten</a> ändern und erweitern.<br><br>
Es handelt sich hierbei um Shellskripte, welche die eigentlichen Funktionen der dtmfbox implementieren (Anrufbeantworter, Callback/Callthrough, ...).<br>
<br>
Alle Skripte werden durch das Menü-Plugin ausgeführt. Die einzelnen Skriptaufrufe stehen in den Bereichen <a href="$MAIN_CGI&page=help&help=menu_script"><font class='code'>[script:X]</font></a>.<p>

Jedem Skript können Parameter mitgegeben werden, die in den Variablen \$1 bis \$32 zur Verfügung stehen. Dies können <a href='$MAIN_CGI&page=help&help=ereignisse'>Ereignisse</a> sein, aber auch benutzerdefinierte Parameter.<p>
Man kann weitere Skripte unter <font class='code'>/var/dtmfbox/script</font> ablegen, welche automatisch mitgespeichert werden.
EOF

fi

#
# Nachrichten
#
if [ "$HELPPAGE" = "nachrichten" ];
then
echo '<a name="nachrichten" href="#nachrichten"></a>'
show_title "Nachrichten"
cat << EOF
Der Menüpunkt "<a href='$MAIN_CGI&page=am_messages' target='_new'>Nachrichten</a>" zeigt die Aufnahmen auf dem Anrufbeantworter an.<br><br>
Es kann zwischen den einzelnen Accounts gewechselt werden. Aufnahmen lassen sich abhören und löschen.<br><br>

Wird das "FTP-Streaming" verwendet, werden die Dateien auf dem FTP-Server abgelegt und stehen dort als RAW-PCM zur verfügung (8000hz/16bit/mono). Das sind ganz normale Wave-Dateien, jedoch ohne Header.
Gespeicherte Aufnahmen sind im WAV-PCM Format (8000hz/16bit/mono).
EOF
fi

#
# Webphone
#
if [ "$HELPPAGE" = "webphone" ];
then
echo '<a name="webphone" href="#webphone"></a>'
show_title "Webphone"
cat << EOF
Unter "<a href='$MAIN_CGI&page=webphone' target='_new'>Webphone</a>" befindet sich ein Java-Applet, womit es möglich ist, über die Weboberfläche, per Headset, zu telefonieren.<br><br>

Es wird das Standard-Sounddevice verwendet. Account auswählen, Zielrufnummer eingeben und wählen.<br><br>

<i>Achtung:</i> Alpha!! ;-)<br><br>

Für das Webphone wird die Java Runtime Engine benötigt.<br>
Download hier: <a href="http://www.java.com/de/download/" target="_new">http://www.java.com/de/download/</a><br>

EOF
fi

#
# dtmfbox Befehle
#
if [ "$HELPPAGE" = "befehle" ];
then
echo '<a name="befehle" href="#befehle"></a>'
show_title "Befehle"
cat << EOF
Die dtmfbox und die Plugins stellen eine Reihe von Befehlen zur Verfügung, welche über Kommandozeile oder über eine Funktion innerhalb der Plugins augerufen werden können.<br><br>
Um Befehle auszuführen, muss die dtmfbox gestartet sein.<br><br>
EOF

echo "Standard-Befehle (<font class='code'>dtmfbox</font>):"
echo -n "<pre class='code'>"
if [ ! -z "$(pidof "dtmfbox")" ]; then
	/var/dtmfbox/dtmfbox
else
	echo -n "dtmfbox wurde nicht gestartet!"
fi
echo "</pre>"
echo "<br>Plugins (<font class='code'>dtmfbox -list plugins</font>):"
echo -n "<pre class='code'>"
if [ ! -z "$(pidof "dtmfbox")" ]; then
	/var/dtmfbox/dtmfbox -list plugins
else
	echo -n "dtmfbox wurde nicht gestartet!"
fi
echo -n "</pre>"

fi

#
# dtmfbox Webinterface
#
if [ "$HELPPAGE" = "webinterface" ];
then
echo '<a name="webinterface" href="#webinterface"></a>'
show_title "Webinterface"
cat << EOF
Die Einstellungen der dtmfbox werden zur Laufzeit ausgelesen und dynamisch angezeigt.<br><br>
Dies trifft hauptsächlich auf die Dateien <i>dtmfbox.cfg</i> und <i>script.cfg</i> zu, wobei Letzere interessant sein kann, um benutzerdefinierte Skripteinstellungen zu hinterlegen.<br>
<br>
Jeder Einstellung wird im Text-Editor ein Kommentar zugewiesen:<br>
<ul>
<li><b>dtmfbox.cfg:</b> <font class='code'>Einstellung=Wert // Kommentar</font>
<li><b>script.cfg:</b> <font class='code'>Einstellung="Wert" # Kommentar</font>
</ul>
Dieser Kommentar wird als Bezeichnung für die Einstellung verwendet. Klickt man nun auf "Speichern" und verlässt den Text-Editor, stellt man fest, das die Einstellung mit dem jeweiligen Kommentar, als Textbox, angezeigt wird.<br><br>
Es gibt weitere Flags, um die Darstellung und das Verhalten von Einstellungen zu verändern.<br>
Diese werden ebenfalls im Kommentarteil angegeben:
<ul>
<li><pre class="code">[HTML:X]<br></pre>
HTML-Code angeben, für Überschriften, Javascript, etc. (X = HTML-Code)</li>

<li><pre class="code">[HIDE:1]<br></pre>
Einstellung verbergen</li>

<li><pre class="code">[WIDTH:X]<br></pre>
Textbox Breite (in px)</li>

<li><pre class="code">[OPTION:X1|Y1|X2|Y2 ...]<br></pre>
Kombobox anzeigen mit vorgegebenen Optionen.<br>
X1/X2 = Wert, der gespeichert wird<br>
Y1/Y2 = Wert, der angezeigt wird
</li>

<li><pre class="code">[TYPE:X]<br></pre>
Input-Type direkt angeben (z.B. X=password)</li>

<li><pre class="code">[ONCHANGE:function()]<br></pre>
Javascript-Funktion aufrufen, wenn der Wert geändert wird. Eine Javascript-Funktion kann mittels [HTML:X]-Tag angegeben werden.
</li>

<li><pre class="code">[SECTION:X]<br></pre>
Einen neuen Bereich erzwingen (X = Bereichsname)</li>
EOF
fi

#
# dtmfbox Befehle
#
if [ "$HELPPAGE" = "ereignisse" ];
then
echo '<a name="ereignisse" href="#ereignisse"></a>'
show_title "Ereignisse"
cat << EOF
Ereignisse geben Auskunft über den aktuellen Zustand einer Verbindung.<br><br>
Hierüber kann man feststellen, ob eine Verbindung gerade aufgebaut wird (<font class='code'>CONNECT</font>), ob ein DTMF-Zeichen empfangen wurde (<font class='code'>DTMF</font>), ob aufgelegt wurde (<font class='code'>DISCONNECT</font>), usw...
Zudem stehen einem noch weitere Informationen zur Verfügung, wie die Account-ID, Account-MSN/-Nummer, die Anrufernummer, Connection-ID, usw.<br><br>

In Menüs können Ereignisse als Parameter an <a href='$MAIN_CGI&page=help&help=menu_script'>Skripte</a> und <a href='$MAIN_CGI&page=help&help=menu_lib'>Libraries</a> übergeben werden.<br>
Zudem können Ereignisse genutzt werden, um Skripte bei bestimmten Verbindungszuständen auszuführen (<a href='$MAIN_CGI&page=help&help=menu_action'>Aktionen</a>).<p>

Übersicht der Ereignisse:<br>
<pre class='code'>
%event%       // Aktuelles Ereignis (DDI, EARLY, CONNECT, CONFIRMED, DTMF, UNCONFIRMED, DISCONNECT)
%direction%   // Verbindungsrichtung (INCOMING, OUTGOING)
%type%        // Verbindungstyp (CAPI, VOIP, USER)
%src_id%      // Source Connection-ID (eigene Verbindungs-ID)
%dst_id%      // Target Connection-ID (Gesprächspartner-ID)
%src_no%      // Rufnummer (Account/MSN)
%dst_no%      // Anrufer oder Zielrufnummer
%acc_id%      // Account-ID
%data%        // DTMF-Zeichen, wenn %event%=DTMF (Aktuell, einzelnes Zeichen), bzw. Statuscode
%dtmf%        // DTMF-Zeichen (Buffer, gesammelte Zeichen).
</pre>
<ul>
<li><font class='code'>%event%</font> ist der aktuelle Verbindungsstatus:
<ul>
	<li><font class='code'>DDI</font> tritt beim Wählen auf, bevor die Verbindung aufgebaut wird</li>
	<li><font class='code'>EARLY</font> tritt bei ausgehenden Verbindungen auf, nachdem gewählt wurde</li>
	<li><font class='code'>CONNECT</font> signalisiert einen neuen ankommenden, bzw. ausgehenden Anruf</li>
	<li><font class='code'>CONFIRMED</font> wird ausgelöst, sobald eine Sprachverbindung aufgebaut wurde</li>
	<li><font class='code'>UNCONFIRMED</font> wird ausgelöst, sobald eine Sprachverbindung abgebaut wurde</li>
	<li><font class='code'>DISCONNECT</font> signalisiert das Beenden einer Verbindung</li>
</ul></li>
<li><font class='code'>%direction%</font> ist die Richtung der Verbindung. <font class='code'>INCOMING</font>, <font class='code'>OUTGOING</font>.</li><br>
<li><font class='code'>%type%</font> ist der Verbindungstyp. <font class='code'>CAPI</font>, <font class='code'>VOIP</font> oder <font class='code'>USER</font>. <font class='code'>USER</font> ist die Verbindung eines angemeldeten SIP-Clients.</li><br>
<li><font class='code'>%src_id%</font> ist einer der wichtigsten Parameter. Es ist die eigene Verbindungs-ID, welche für fast alle Befehle gebraucht wird. Damit kann man Befehle auf die aktuelle Verbindung anwenden, wie z.B. Wave-Datei abspielen/aufnehmen, Gespräch annehmen/auflegen, usw.</li><br>
<li><font class='code'>%dst_id%</font> ist die Verbindungs-ID des Gesprächspartners, mit dem man verbunden ist. Bei mehreren Gesprächspartnern, wird immer nur der Erste übergeben.</li><br>
<li><font class='code'>%src_no%</font> ist die Rufnummer der aktuellen Verbindung. Normalerweise die Rufnummer des Accounts.</li><br>
<li><font class='code'>%dst_no%</font> ist die Rufnummer des Gesprächspartners</li><br>
<li><font class='code'>%acc_id%</font> ist die Account-ID der aktuellen Verbindung</li><br>
<li><font class='code'>%data%</font> gibt zusätzlich bei <font class='code'>%event%="DISCONNECT"</font> den Grund für den Verbindungsabbau/-abbruch an (SIP/CAPI Statuscode).<br>Ansonsten dient <font class='code'>%data%</font> dazu, das aktuell übertragene DTMF-Zeichen zurückzuliefern (<font class='code'>%event%="DTMF"</font>).</li><br>
<li><font class='code'>%dtmf%</font> ist der komplette DTMF-Buffer (<font class='code'>%event%="DTMF"</font>)</li><br>
</ul><br>
EOF
fi

#
# Inhalt / Menüleiste
#
cat << EOF
  </td>
  <td valign="top" width="20%">
<br>
<b>Hilfe</b>
<hr color="black">
  <ul>
	<li><a href="$MAIN_CGI&page=help&help=vorwort">Vorwort</a></li>
	<li><a href="$MAIN_CGI&page=help&help=getting_started">Getting started...</a></li>
	<br>
	<li><a href="$MAIN_CGI&page=help&help=status">Status</a></li>
	<li><a href="$MAIN_CGI&page=help&help=basiseinstellungen">Basiseinstellungen</a></li>
	<ul>
		<li><a href="$MAIN_CGI&page=help&help=accounts">Accounts einrichten</a></li>
		<li><a href="$MAIN_CGI&page=help&help=internes_menu">Kurzwahlen einrichten</a></li>
	</ul>

	<li><a href="$MAIN_CGI&page=help&help=skripteinstellungen">Skripteinstellungen</a></li>
	<br>
	<li><a href="$MAIN_CGI&page=help&help=menu_start">Das Menü</a></li>
	<li><a href="$MAIN_CGI&page=help&help=menu">Menü bearbeiten</a></li>
	<ul>
		<li><a href="$MAIN_CGI&page=help&help=menu_menu">menu:</a></li>
		<li><a href="$MAIN_CGI&page=help&help=menu_script">script:</a></li>
		<li><a href="$MAIN_CGI&page=help&help=menu_lib">lib:</a></li>
		<li><a href="$MAIN_CGI&page=help&help=menu_action">action:</a></li>
	</ul>

	<li><a href="$MAIN_CGI&page=help&help=skripte_bearbeiten">Skripte bearbeiten</a></li>
	<br>
	<li><a href="$MAIN_CGI&page=help&help=nachrichten">Nachrichten</a></li>
	<li><a href="$MAIN_CGI&page=help&help=webphone">Webphone</a></li>
	<br>
	<li><a href="$MAIN_CGI&page=help&help=befehle">dtmfbox Befehle</a></li>
	<li><a href="$MAIN_CGI&page=help&help=ereignisse">dtmfbox Ereignisse</a></li>
	<li><a href="$MAIN_CGI&page=help&help=webinterface">dtmfbox Webinterface</a></li>
  </ul><br>

  </td></tr></table>
  </body>
  </html>
EOF
