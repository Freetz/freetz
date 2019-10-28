# Add support for multiple printers
Ermöglicht die Nutzung mehrere Drucker an der FritzBox.<br>
<br>

Dieser Patch baut auf der Idee aus ​[diesem Beitrag](http://www.ip-phone-forum.de/showthread.php?t=161756&p=1075666) auf, angeschlossene Drucker und den jeweiligen Printserver-Port mittels des physikalischen USB-Ports aneinander zu koppeln. Damit ist eine feste Zuordnung gewährleistet.

Da der AVM-Printserver jeweils zwei Ports belegt (n+1), wird immer ein Port übersprungen:

```
phys. USB-Port 0 => Port 9100
phys. USB-Port 1 => Port 9102
phys. USB-Port 2 => Port 9104
...
```

Alle Drucker sollten an dem gleichen USB-Hub angeschlossen werden. Prinzipiell sind mit Einschränkungen aber auch unterschiedliche Hubs möglich.
In der Übersicht "USB-Geräte" werden alle angeschlossenen Drucker mit den vergebenen Printserver-Ports aufgelistet.
Der Drucker am phys. USB-Port 0 (Port 9100) wird zudem - sofern angeschlossen - immer als Standard-Drucker (Device-Node /dev/usblp0) registriert. Das macht spätestens dann Sinn, wenn die Fritz Box mal eigene Druckfunktionen (wie z.B. einen direkten Faxausdruck) mitbringen sollte.

### Einschränkungen

Der dargestellte Druckerstatus wechselt beliebig zwischen den angeschlossenen Druckern.

—by IPPF User thimo

### Weiterführende Links

    ​http://www.ip-phone-forum.de/showthread.php?t=161756
    ​http://www.ip-phone-forum.de/showthread.php?t=195811 


