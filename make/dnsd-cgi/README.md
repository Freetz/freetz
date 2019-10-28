# dnsd-cgi

Schlanker DNS-Server für statische Namensauflösung (BusyBox Applet)

### Links

-   [Man
    page](http://www.busybox.net/downloads/BusyBox.html#dnsd)

### Beispielkonfiguration

Port 53 mit [AVM firewall CGI](../avm-firewall/README.md) nach 10053
mappen wo [iodine](../iodine/README.md) läuft. Dieses leitet Anfragen
unbekannter Domains auf Port 5353 weiter wo *dnsd* läuft. *dnsd*
beantwortet für ein paar Subdomains diese Anfragen.

