# Remove dsld
Entfernt den DSL-daemon - die Box kann dann nur noch als IP-Client verwendet werden.
Achtung! Ohne dsld kann die Box keine DSL-Verbindung aufbauen und auch "Internet über LAN" geht nicht mehr, weil der dsld auch Firewall und NAT übernimmt.<br>
<br>

Der DSLd ist ```ein AVM-Deamon der sich um das DSL-Interface kümmert. Auf der FBF 7050 macht er auch das NAT für alle Pakete die duch sein Interface gehen.``` (Fritzbox-Wiki).
Wer seine Box also nicht für die DSL-Einwahl nutzt (sondern z.B. hinter einer anderen Fritzbox, die sich um DSL etc. kümmert), kann durch Entfernen des DSLd ein wenig Platz im Image schaffen.

 * Alle anderen sollten besser die Finger davon lassen ;)

### Weiterführende Links

 * [Fritzbox-Wiki: DSLd](http://www.wehavemorefun.de/fritzbox/index.php/Dsld)
 * [​Blog: Fritz!Box re-connect](http://blog.gauner.org/2008/03/19/fritzbox-reconnect/)

