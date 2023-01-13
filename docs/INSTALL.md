# INSTALL: Freetz installieren/flashen
Was man tun muss um Freetz auf seine Fritzbox zu bekommen.

### Installationswege
Es gibt 3 Wege ein Firmware auf eine Fritzbox zu installieren:
 * __AVM Webinterface__:<br>
   Es können alle AVM und Freetz Images installiert werden - gilt ab etwa Fritzos 6.5 nicht mehr.<br>
   Seitdem prüft AVM die Signatur der hochgeladenen Datei. Diese Signatur kann nur von AVM erstellt werden und es werden keine modifizierten Images akzeptiert.<br>
   Falls man bereits ein __SELBST__ signiertes Freetz Image (default) installiert hat enthält dises einen zusätzlichen Signaturkey und es können mit dem __GLEICHEN__ Key signierte Images installiert werden.<br>
 * __Freetz Webinterface__:<br>
   Es können alle AVM und Freetz Images installiert werden, es gibt keine Signaturprüfung. Ein Downgrade ist auch möglich.<br>
 * __Bootloader/Urlader/ADAM2/ADAM/EVA/FTP__:<br>
   Es können alle AVM und Freetz Images installiert werden, es gibt keine Signaturprüfung. Je nach Gerät muss die korrekte Methode genutzt werden<br>

Für die Erstinstallation bleibt somit nur der ...

### Bootloader
Welche Methode für den Bootloader genutzt werden muss hängt vom Gerät hab.
Grundsätzlich funktioniert `push_firmware` von Freetz-NG (!) mit allen Methode.
Es gibt einige weitere Tools und Scripte, eigentlich kann man (wenn man es kann) auch ohne diese von Hand mit einer FTP-Verbindung installiere. 
Der Bootloader hat die IP `192.168.178.1` und ist nicht die IP die man im Webinterface konfiguriert. Man greift via FTP darauf zu.
Wenn man nicht weiss wie man diese verändert, hat man sie sicherlich auch nicht verändert.
Ein paar Sekunden nachdem die Fritzbox an den Strom angeschlossen ist ist der Bootloader dieser für wenige Sekunden erreichbar.
Falls man den Zeitpunkt verpasst hat muss man es solange versuchern bis das Timing passt.
Zwischengeschaltete Netzwerkgeräte wie Switches können einen positiven oder negativen Effekt haben.
Reagiert das Gerät zu zäh und Netzwerkerkennung (media detect/sense) braucht zu lange kann der Zeitpunkt schon vorbei sein.
Um die Fritzbox im Bootloader anzuhalten kann man eine recovery.exe irgend einer __ANDEREN__ Fritzbox nutzen.

### Methoden
Verfügbare Scripte und Tools zum Flashen über den Bootloader:

 * Gen 1+2: __single-boot__<a id='single'></a> / NOR<br>
   Die ersten Fritzboxen von 7050 bis 7390
    - `tools/push_firmware` von Freetz-NG
    - [push_firmware](https://www.freetz.org) vom Ur-Freetz
    - [fritzflash.py](https://fritz-tools.readthedocs.io) von Freifunk/Gluon
    - [ruKernelTool](http://rukerneltool.rainerullrich.de/) gibt es zum Glück nicht mehr
 
 * Gen 3: __ram-boot__<a id='ram'></a> / NAND / inmemory<br>
   Fritzboxen nach 7390, wie 7490 & 7590
    - `tools/push_firmware` von Freetz-NG
    - [eva_tools](http://www.yourfritz.de/desc-eva) aus [YourFritz](https://github.com/PeterPawn/YourFritz/tree/main/eva_tools) für Windows/PowerShell<br>
      Vorsicht: Dieses Script kann kein Image flashen, sondern nur das soganannte <br>`inmemory`-Zwischenformat. Siehe dazu `tools/image2inmemory`

 * Gen 6: __fit-boot__<a id='fit'></a><br>
   Neueste Fritzboxen wie 7530 AX & 5530
    - `tools/push_firmware` von Freetz-NG
    - [fit_tools](https://github.com/PeterPawn/YourFritz/tree/main/fit_tools) von YourFritz,
      wird in Freetz-NG für den AVM spezifische Header bzw<br>Signatur genutzt. Danach können DTC und U-Boot verwenden werden.

 * Gen 4: __dual-boot__<a id='dual'></a><br>
   Alte Cable Fritzboxen mit Puma6, zb 6490 & 6590
    - `tools/push_firmware` von Freetz-NG

 * Gen 5: __uimg-boot__<a id='uimg'></a><br>
   Neue Cable Fritzboxen mit Puma7, zb 6591 & 6660
    - `tools/push_firmware` von Freetz-NG<br>
    - [uimg-tool](https://bitbucket.org/fesc2000/uimg-tool.git) von fesc2000 zum ent-/packen, wird in Freetz-NG genutzt
    -  Infos zur BIOS-Version bei [ffritz von fesc2000](https://bitbucket.org/fesc2000/ffritz/src/6591/README-6591.md)

Um es kurz zusammenzufassen: Einfach `tools/push_firmware` verwenden und den Rest vergessen ...

### push_firmware
 * Um alle möglichen Optionen anzuzeigen: `tools/push_firmware --help`
 * Alternativ kann es auch mit `make push_firmware` aufgerufen werden, Parameter sind dann nicht möglich.
 * Ohne Parameter wird das zuletzt erzeugte Image genutzt.
 * Wenn man nicht weiss weshalb man einen Parameter angegeben halt sollte man diesen weglassen! Es müsste alles automatisch erkannt werden.

### Anmerkungen
 * Die Namen hier wie zB NOR, NAND oder INHAUS sind meist keine offiziellen Bezeichnungen sondern Vereinbarungen oder Anlehnungen.
 * Es gibt dazu noch sehr viel zu lesen, mindestens in diversen Foren (IPPF, IPF) und auf GitHub (Freetz-NG, YourFritz).
 * Mit Fritzbox sind auch die anderen Dinger von AVM gemein die nicht Fritzbox heissen.

