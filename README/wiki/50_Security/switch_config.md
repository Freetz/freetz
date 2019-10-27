# Konfiguration des eingebauten Switches

(für unterstützte Modelle siehe
unten)

For 7390 read this
[post](http://www.ip-phone-forum.de/showthread.php?t=287518&p=2185822&viewfull=1#post2185822).
For 7490 it should be possible by altering ar7.cfg. See the following
threads:
[1](http://www.ip-phone-forum.de/showthread.php?t=273927),
[2](http://www.ip-phone-forum.de/showthread.php?t=272055)
and
[3](http://www.ip-phone-forum.de/showthread.php?t=275391),
and possible others.

### Vorwort

Einige Modelle aus der FritzBox-Familie besitzen nicht nur einen
LAN-Port, sondern gleich vier, z.B. die 7170. Da ich selber nur die 7170
"persönlich" kenne, möge man die nachfolgenden Worte in erster Linie
als Anleitung/Beschreibung für dieses Modell verstehen, andere Boxen
bitte ergänzen.

Im Normalbetrieb der 7170 arbeiten die vier Ports wie ein normaler
[Switch](http://de.wikipedia.org/wiki/Switch_(Computertechnik)),
d.h. alle angeschlossenen Geräte befinden sich im gleichen Subnetz und
können direkt miteinander kommunizieren. Mit Hilfe der Originalfirmware
von AVM ist es aber auch möglich, den LAN 1-Port als WAN-Port zu nutzen
(im Webinterface *"Internetzugang via LAN 1"* auswählen), z.B. wenn
man die Box an einem Kabelmodem o.ä. betreiben will. Dazu wird der Port
von den verbleibenden drei Ports getrennt und wird als separates
WAN-Netzwerkgerät von der Firmware entsprechend konfiguriert.

Das ist möglich, da in der FritzBox ein konfigurierbarer 5-Port-Switch
eingebaut ist: vier der Ports sind als LAN 1 bis 4 nach außen geführt,
am fünften hängt die eigentliche FritzBox, sprich die CPU. Leider bietet
AVM im Webinterface keine Möglichkeit, die Ports weitergehend
individuell zu konfigurieren. Da dies in bestimmten Fällen aber sehr
hilfreich wäre, entstand das kleine Tool
[cpmaccfg](http://www.heimpold.de/dsmod/). Es kann
via Telnet/SSH-Zugang auf der FritzBox ausgeführt - oder aber mit
Freetz direkt in das Firmware-Image
eingebunden werden.

AVM hat die Schnittstelle für die Switchkonfiguration in den
Linux-Netzwerkkartentreiber (*avm_cpmac*) eingebunden, offenbar gibt es
da eine "alte" und eine "neue" Version dieser Schnittstelle. Während
die alte noch sehr weitgehenden Zugriff auf den Switch erlaubt und es
ermöglicht, das volle Potential des Switches auszuschöpfen, ist die neue
etwas "abstrakter" gehalten, was dazu führt, dass man nur noch
zwischen verschiedenen vordefinierten Konfigurationen auswählen kann.
Wer vollen Zugriff braucht, kann aber die alte Schnittstelle durch
Hinzufügen von 2 Zeilen Kernelquellcode wieder aktivieren. In Freetz
passiert dies beim Einbinden von `cpmaccfg` automatisch, wenn in
menuconfig `replace kernel`
ausgewählt wird.

Das Tool cpmaccfg funktioniert auch beim Speedport W900V.

### Vordefinierte Switch-Konfigurationen

AVM selbst hat im Kernelmodul schon verschiedene vordefinierte
Konfigurationen hinterlegt, eine ist davon ist die bereits erwähnte
Variante "Internetzugang via LAN 1", intern als ATA-Modus bezeichnet.
Hier ein Überblick über alle vordefinierten Modi:

-   **normal**: alle vier Ports arbeiten wie ein normaler Switch, der
    Kernel verwendet eth0 als Netzwerkinterface (jenachdem, ob "Alle
    Computer befinden sich im selben Subnetz" angekreuzt ist, wird
    *eth0* noch mit den WLAN-Interfaces zu einem "lan"-Interface
    zusammengebridged)
-   **ata**: LAN 1 kommt im Kernel als "wan" an, die drei anderen
    Ports als "eth0" (eventuelle Einbindung von *eth0* in Bridge wie
    im Normalmodus)
-   **split**: jedem Port wird ein einzelnes Interface zugeordnet, also
    "eth0", "eth1"...
-   **split_ata**: wie split, jedoch bekommt LAN 1 die Bezeichnung
    "wan"
-   **all_ports**: im Grunde wie normal, genauer Sinn & Zweck noch
    unbekannt (eventuell für Boxen mit mehr als 4 Ports gedacht?)
-   **special**: siehe unten

Richtig Sinn ergibt das Wechseln des Modus natürlich nur, wenn man das
Häkchen bei *"Alle Computer befinden sich im selben Subnetz"*
[nicht]{.underline} setzt, weil sonst alle verfügbaren Devices in eine
Bridge gesteckt werden.
**UPDATE:** Es funktioniert ebenfalls sauber im
"ethmode=ethmode_bridge" da dann die Devices aus der
"Bridge"-Sektion genommen werden (und eben **nicht** aus der
"eth"-Sektion).
Im "Eth-Bridge"-Modus werden diese "einzelnen" "realen" ethX dann
jeweils in die angegebene Bridge intergiert. Ist ganz praktisch wenn man
das USB Device ("usbrndis") mal zu einem der 4 Ports zuordnen möchte.
Der Trick dabei ist das konfigurierte ethx-IF in der "eth"-Sektion
auch in der Bridge-Sektion aufgeführt sind.

Beispiel:\
Man möchte LAN1 und LAN4 als eth2 und LAN2 und LAN3 als eth0
konfigurieren.
Dann hat man in der "eth-Sektion" eth0 und eth2 und in der
Bridge-Sektion z.B. die Bridge lan (mit if eth0) und Bridge xnet (mit if
eth2)\
Hat man beides in der ar7.cfg sauber stehen kann man problemlos zwichen
"ethmode=ethmode_bridge" und "ethmode=ethmode_router"
("AVM-deutsch: "alle Computer befinden sich im selben Netzwerk")
umschalten (Haken setzen oder auch nicht). Und eben jetzt kann man im
"ethmode=ethmode_bridge" z.B. der Bridge "xnet" die Interfaces eth2
und usbrndis zuordnen. Wie genau die ar7.cfg konfiguriert wird steht
weiter unten in diesem Artikel.

Den aktuellen Modus kann man mit Hilfe von `cpmaccfg gsm` abfragen,
setzen ist mit `cpmaccfg ssm <zielmodus>` möglich.

### Modus "special"

Mit einem gepatchtem Kernel ist auch möglich, eigene individuelle
Port-Konfigurationen zu erstellen. Dazu dient der Modus "special", der
quasi als Platzhalter für eine Konfiguration im Kernel vorhanden ist.
Dieser Platzhalter muss zunächst mittels `cpmaccfg ssms ...` gefüllt
werden, anschließend kann mit `cpmaccfg ssm special` auf diese
Konfiguration umgeschaltet werden.

### Patch des Standard-Modus

Die Nutzung des Special-Modus hat den Nachteil, dass die Modus erst
während des Startvorganges der Box aktiviert werden muss. Bei einer
Änderung des standardmäßig in der Box verwendeten Modus, wie z.B.
`NORMAL` oder `ATA`, wird der Switch automatisch beim Starten der Box
passend aufgeteilt.

Für diese Änderung ist es notwendig, den gewünschten Modus in der Datei
`linux-2.6.19.2/drivers/net/avm_cpmac/cpphy_adm6996.c` zu patchen. Das
folgende Beispiel beschreibt die Aufteilung des Switch in die beiden
Interface eth0 mit LAN1 und LAN2 sowie eth1 mit LAN3 und LAN4. Der
folgende Patch wurde für eine 7270 mit Firmware 76 erstellt.

```
  --- linux-2.6.19.2/drivers/net/avm_cpmac/cpphy_adm6996.c_orig   2009-06-08 13:59:52.000000000 +0200
  +++ linux-2.6.19.2/drivers/net/avm_cpmac/cpphy_adm6996.c        2009-08-20 10:57:14.000000000 +0200
  @@ -137,9 +137,10 @@
                                           { {"", 0x0}
                                           }
                                      },
  -        /* CPMAC_MODE_NORMAL    */ { 1, 0xff,
  -                                        { {"eth0", 0x2f}
  -                                        }
  +        /* CPMAC_MODE_NORMAL    */ { 2, 0xff,
  +                                        { {"eth0", 0x23},
  +                                                 {"eth1", 0x2c}
  +                                       }
                                      },
           /* CPMAC_MODE_ATA       */ { 2, 0,
                                           { {"wan",  0x21},
```

Den Patch in das Verzeichnis `/make/linux/patches/2.6.19.2` oder ggf.
Unterordner wie z.B. `7270_04.76` kopieren.

```
  make menuconfig
```

Box konfigurieren und die Option "Replace Kernel" auswählen

Bestehenden Kernel löschen:

```
  make kernel-dirclean
```

Kernel-Sourcen bereitstellen und Patchen

```
  make kernel-source
```

Hier kann noch kontrolliert werden, ob der Patch korrekt durchgeführt
wird. z.B.:

```
  applying patch file make/linux/patches/2.6.19.2/7270_04.76/990-cpmac.patch
  patching file linux-2.6.19.2/drivers/net/avm_cpmac/cpphy_adm6996.c
```

Dann noch das Image erstellen:

```
  make
```

### Anpassungen in der ar7.cfg

Die Anpassungen der ar7.cfg stellen sicher, dass die Änderungen auch bei
verschiedenen Konfiguationsänderungen, wie z.B. Aus- und Einschalten des
Wlan bestehen und und automatisch konfiguriert werden und bleiben.

Kopie der ar7.cfg erstellen und diese bearbeiten:

```
  cd /var/tmp
  cat /var/flash/ar7.cfg > ar7.cfg
  vi ar7.cfg
```

Box muss sich im Modus "Router" befinden, dies wird mit der Option
`ethmode` in der ar7.cfg eingestellt.

```
  ethmode = ethmode_router;
```

Dann muss noch der Bereich `ethinterfaces` verändert werden.

Bei der Konfiguration ist folgendes zu beachten. Nur den dort
vorhandenen wird eine IP-Adresse zugewiesen. Alle anderen Interfaces
existieren zwar und können über ifconfig abgefragt oder ggf. manuell
konfiguriert werden.

Bei den Devices kann über die Option "interfaces" Bridges automatisch
gebildet werden. Das folgende Beispiel beschreibt die Konfiguration
zweier Devices intern und extern.

Das Device `extern` wird aus dem Interface "eth1" mit der Adresse
192.168.1.1 gebildet, das Device `intern` aus eth0 und den verschiedenen
WLan-Interfaces mit der Adresse 192.168.0.1.
**UPDATE**: Wie ihr seht funktioniert das "bridgen" bereits auch
sauber in der eth-Sektion! (und AVM hat es ja auch selber mit dem
wlan-IF so gemacht)

```
        ethinterfaces {
                name = "extern";
                dhcp = no;
                ipaddr = 192.168.1.1;
                netmask = 255.255.255.0;
                dstipaddr = 0.0.0.0;
                interfaces = "eth1";
                dhcpenabled = no;
                dhcpstart = 0.0.0.0;
                dhcpend = 0.0.0.0;
        } {
                name = "eth0:0";
                dhcp = no;
                ipaddr = 169.254.1.1;
                netmask = 255.255.0.0;
                dstipaddr = 0.0.0.0;
                dhcpenabled = yes;
                dhcpstart = 0.0.0.0;
                dhcpend = 0.0.0.0;
        } {
                name = "intern";
                dhcp = no;
                ipaddr = 192.168.0.1;
                netmask = 255.255.255.0;
                dstipaddr = 0.0.0.0;
                interfaces = "eth0", "ath0", "wdsup1", "wdsdw1", "wdsdw2",
                             "wdsdw3", "wdsdw4";
                dhcpenabled = no;
                dhcpstart = 192.168.0.20;
                dhcpend = 192.168.0.200;
        }
```

Dann die bestehende `ar7.cfg` durch die veränderte Datei überschreiben:

```
    cat /var/tmp/ar7.cfg > /var/flash/ar7.cfg
```

Dann die Änderungen mit einen Reboot oder `ar7cfgchanged` aktivieren.

Ergänzung:\
Auch der special Modus kann über die ar7.cfg konfiguriert werden.
Als Beispiel ein Ausschnitt aus einer Alice Konfiguration)

```
  cpmacspecial {
        enabled = yes;
        normalcfg = "eth0,1,2,3", "eth3,4";
        atacfg = "wan,1", "eth0,2,3", "eth3,4";
    }
```

und ein Anderes mit "split" Interfaces\

```
	cpmacspecial {
		enabled = yes;
		normalcfg = "eth0,1", "eth1,2", "eth2,3", "eth3,4";
		atacfg = "wan,1", "eth1,2", "eth2,3", "eth3,4";
	}
```

Der Syntax:

```
	modus = portmapping[, ...]

	modus =: normalcfg|atacfg
	portmapping =: "netdevname,portnum[,...]"
	netdevname =: wan|eth[0-3]) (aber
	vielleicht auch eigener Namen)
	portnum =: [1-4] (so vielen wie es auf das
	Gerät gibt)
```

### Beispiel

Die vier Ports sollen in zwei Gruppen aufgeteilt werden: LAN 1 und LAN 2
sollen für das interne Netz zur Verfügung stehen (als eth0), LAN 3 und
LAN 4 werden zwei
[Freifunk](http://www.freifunk.net/)-Router
angeschlossen, die zusammen in einem separaten Subnetz stecken (als
*eth1*), vom internen LAN also getrennt sein sollen.

Ruft man `cpmaccfg` ohne weitere Parameter auf, erscheint eine knappe
Übersicht über Kommandos und Parameter. Damit ermittelt man, welche
*PORTMASK* für die jeweiligen Interfaces zu verwenden ist. Diese
Portmaske ergibt sich aus der Logischen-Oder-Verknüpfung der jeweiligen
Portkonstanten. Das sind folgende Werte: LAN 1 = 0x01, LAN 2 = 0x02, LAN
3 = 0x04, LAN 4 = 0x08 und der CPU-Port ist 0x20.

Für das obige Beispiel muss also folgender Befehl aufgerufen werden:

```
	cpmaccfg ssms eth0 0x23 eth1 0x2c
```

Man beachte, dass in beiden Portmasken der CPU-Port eingeschlossen
wurde. Macht man dies nicht, entsteht zwar das Interface, es "sieht"
aber keinen Traffic (noch nicht probiert, zu überprüfen).

Anschließen kann mit `cpmaccfg ssm special` diese Konfiguration
aktiviert werden.

### Sicherheits-Warnung

Beim Booten startet die Box immer im Modus **normal**, d.h.: wie und wo
man auch immer die Umschaltung in den gewünschten Modus realisiert (z.B.
per `debug.cfg` oder in einem Freetz Startup-Skript), es existiert immer
eine gewisse Zeitspanne, in der sich alle vier Ports im gleichen "Layer
2-Subnetz" befinden. Erst nachdem die Umschaltung erfolgt ist, befinden
sich die Ports in getrennten "Layer 2-Netzen". Erst dann muss eine
Kommunikation über Layer 3 (IP-Ebene) erfolgen, wo eventuelle
iptables-Regeln greifen (oder halt die interne AVM-Firewall).

Schon bevor der Kernel bootet, wird der Switch vom Bootloader als
normaler Switch konfiguriert. Die Konfiguration im Kernel umzustellen
verkürzt die Zeitspanne etwas, beseitigt aber nicht das grundsätzliche
Problem.

Da für den Bootloader keine Quelltexte frei verfügbar sind, wäre ein
Anpassung schwierig.

### Kompatibilität

-   **FB 7170, Speedports W900V, W701V** Diese Boxen haben einen
    eingebauten Switch (ADM6996), `cpmaccfg` funktioniert.
-   **7270/3270** Tantos-Switches: cpmaccfg funktioniert
    ([Beweis](http://www.ip-phone-forum.de/showpost.php?p=1599909&postcount=23))
-   **Alice IAD 5130, Alice IAD WLAN 3331, FB 5140/3170/2170**
    funktionieren ebenfalls problemlos (jeweilige akt. Firmware)
    (cpmaccfg ebenso).
-   **5124** sollte ebenfalls sauber funktionieren
-   **7050** Kein Switch-Baustein vorhanden, es handelt sich um richtige
    Netzwerkinterfaces.
-   **7320** wie 7050/5050 Boxen. Es sind reale Netz-IF (eth0 & eth1)
    welche auch getrennt koniguriert werden können (und das sogar
    permanent in der ar7.cfg im Bridgemode).

### 

### Änderungen 7270v2 vs. 7270v3

Bei der 7270v3/3270v3 hat sich der CPU Port von Bit5 auf Bit0 verschoben
und die Interface Ports sind um eins nach links gerückt. Für das obige
Beispiel muss also folgender Befehl auf der 7270v3 aufgerufen werden:

```
	cpmaccfg ssms eth0 0x07 eth1 0x19

	# eth0: Maske 0000 0111
	# eth1: Maske 0001 1001

	# 7270v3: 0001 1111               7270v2: 0010 1111
	#                 x---- CPU Port -----------x
	#                x----- Port 1   -----------------x
	#               x------ Port 2   ----------------x
	#              x------- Port 3   ---------------x
	#            x--------- Port 4   --------------x
```


