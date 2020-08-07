# SUPPORT
Wie kann ich Freetz-NG unterstützen?

 * **UNTESTED**<br>
   Im ```menuconfig``` und in [FIRMWARES](FIRMWARES.md) sind verschieden Geräte als ```UNTESTED``` markiert.<br>
   Mangels Hardware konnte auf diesen nicht ausprobiert werden ob Freetz-NG funktioniert.<br>
   Falls jemand so ein Gerät erfolgreich mit Freetz-NG betreibt, bitte Rückmeldung geben.<br>
   Am besten gleich mit einem Screenshot von ```Box-Info```.<br>
 * **Quellcode**<br>
   Um ein modifiziertes Image zu erstellen, ist von AVM der passende Quellcode notwendig.<br>
   Da AVM Software nutzt die zB unter der GPL steht, muss dieser Sourcecode herausgegeben<br>
   werden - allerdings nur auf Anfrage!<br>
   Dazu sollte **jeder** für **jedes** seiner Geräte eine E-Mail an [fritzbox_info@avm.de](mailto:fritzbox_info@avm.de) schicken.<br>
   Dies zu **jeder** veröffentlichten FritzOS Version, auch für die sogenannten "Labor".<br>
   AVM veröffentlicht das Paket dann früher oder später auf [osp.avm.de/](https://osp.avm.de/).<br>
 * **Pull request**<br>
   Eigene Änderungen zu Freetz-NG "pushen":
    - Auf [github.com/Freetz-NG/freetz-ng/](https://github.com/Freetz-NG/freetz-ng/) oben mit ```Fork``` einen Fork im eigenen Account erstellen.
	- Eigenen Fork auschecken: ```git clone https://github.com/BENUTZERNAME/freetz-ng.git```
	- Einen Branch erstellen: ```git branch BRANCHNAME``` ; ```git checkout BRANCHNAME``` ; ```git push -u origin BRANCHNAME```
	- Geänderte/hinzugefügte Dateien hochladen: ```git add . ; git commit -m "BESCHREIBUNG" ; git push```
    - Auf [github.com/Freetz-NG/freetz-ng/](https://github.com/Freetz-NG/freetz-ng/) mit ```New pull request``` die eigenen Änderungen abschicken.
  * **Package bump**<br>
    Minimale Schritte um die Version eines Packages zu aktualisieren:
	 - Die Datei ```docs/CHANGELOG.md``` anpassen.
	 - Die Version in ```make/$PKG/Config.in``` anpassen.
	 - Das Wiki aktualisieren durch ausführen von: ```docs/generate.sh```
	 - Die Version in ```make/$PKG/$PKG.mk``` anpassen.
	 - Die Prüfsumme in ```make/$PKG/$PKG.mk``` anpassen.
	 - Vorhandene Patches in ```make/$PKG/patches/``` aktualisieren:<br>
	    ```AUTO_FIX_PATCHES=y make $PKG-unpacked```
	 - Compilieren mit: ``` make $PKG-precompiled FREETZ_VERBOSITY_LEVEL=2```
	 - Falls der Dateiname die Version enthält, ```make/$PKG/external.*``` anpassen.
	 - Libraries befinden sich nicht in ```make/$PKG/``` sondern: ```make/libs/$PKG/```
  * **Wiki**<br>
    Viele Teile des unter [freetz-ng.github.io/](https://freetz-ng.github.io/) zu erreichenden Wikis sind veraltet und bedürfen einer<br>
	Überarbeitung. Alle Datein des Wikis sind im Checkout unter ```docs/wiki/``` zu finden.<br>
    Wichtig: Nach Änderungen unter ```docs/``` oder von ```Config.in```-Dateien ```docs/generate.sh``` zum<br>
	Aktualisieren des Index ausführen.<br>

