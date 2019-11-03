# Replace onlinechanged - EXPERIMENTAL
Onlinechanged wird durch eigenen IP-Watchdog angestoßen (geht auch auf IP-Clients).<br>
<br>

Dieser Patch sorgt dafür, daß die Onlinechanged-Skripten von

 * AVM-Diensten (Verzeichnis /etc/onlinechanged),
 * Freetz-Paketen (Verzeichnis /etc/onlinechanged),
 * Onlinechanged-CGI (Skript /tmp/flash/onlinechanged-cgi) und
 * manuell angelegten Skripten (Verzeichnisse /tmp/onlinechanged und /tmp/flash/onlinechanged) 

von einem eigenen IP-Watchdog angestoßen werden statt vom AVM multid.
<br>
Vorteile dieser Methode gegenüber dem AVM-Mechanismus sind:

 * Sie funktioniert im Gegensatz zur AVM-Methode auch auf Geräten, die keine eigene Internet-Verbindung (z.B. via DSL oder PPPoE) aufbauen, also auf Geräten hinter einem NAT (z.B. bei "Internetverbindung mitbenutzen").
 * In Problemfällen, wo AVM Onlinechanged nicht zuverlässig funktioniert (siehe entsprechendes ​IPPF-Thema) bietet dieser Patch eine zuverlässige Alternative. 

Mehr Hintergründe zur Funktionsweise siehe Hilfetext im "menuconfig".

### FAQ

 * AVM Onlinechanged konnte man auch manuell von der Konsole aus aufrufen via ```onlinechanged online```. Wie geht das beim IP-Watchdog, der doch ständig im Hintergrund läuft?<br>
   Ganz einfach: ```killall ip_watchdog```. Der Befehl beendet die laufende Instanz, ```init``` startet den Watchdog daraufhin sofort neu (wegen der Direktive "respawn" in /etc/inittab).
   Das führt dazu, daß sämtliche Onlinechanged-Skripten einmal ausgeführt werden. Danach läuft es dann normal weiter, d.h. der erneute Aufruf der Skripten erfolgt erst dann wieder,
   wenn sich die externe IP-Adresse ändert. Im Gegensatz zu ```onlinechanged online``` (geht sowieso nur ohne diesen Patch) oder ```/bin/onlinechanged.sh online``` (geht auch mit diesem Patch)
   sorgt die Killall-Methode dafür, daß alles sauber initialisiert wird (z.B. ```IPADDR```, vgl. auch nächste Frage).

 * Wie ermittle ich in eigenen Onlinechanged-Skripten die externe IP-Adresse?<br>
   Der IP-Watchdog ermittelt sie sowieso und übergibt sie in der Umgebungsvariablen ```IPADDR```, welche man in den entsprechenden Skripten verwenden kann.
   Das spart Aufrufe von get_ip und somit ggf. auch Anfragen an externe STUN-Server. 
   Dadurch wird auch ein Caching der IP-Adresse überflüssig. Die Variable ```IPADDR``` wird übrigens auch im AVM-Original von multid bei Aufruf von onlinechanged gesetzt.

