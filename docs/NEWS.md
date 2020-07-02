# NEWS

 * __2020-07-02__<br>
   Nun verhindert eine unspezifische höhere Macht die Herausgabe von Sourcecode.<br>
   Dass die 7369 weder offiziell EOS/EOL ist, noch das Dateidatum der letzt Firmware älter als 3 Jahre ist, konnte<br>
   AVM nicht abstreiten. Der Sourcecode wird dennoch nicht herausgegeben, weil es schlicht "nicht möglich" ist.<br>
   <br>
   AVM schrieb dazu auf eine Anfrage per Mail:<br>
   ```...```<br>
   ```Sie haben vollkommen recht, die 7369 taucht nicht in der EOS-Liste auf, warum das so ist,```<br>
   ```ist mir nicht bekannt. Sie ist bereits seit 2016 EOS. Das letzte Update gab es den mir vorliegen```<br>
   ```Informationen nach 06/2016.```<br>
   ```Aber ganz davon abgesehen, würde es keine entscheidende Rolle spielen, ob jetzt drei Jahre```<br>
   ```überschritten sind oder nicht, wenn wir Ihnen den Quellcode bereit stellen könnten, würden wir```<br>
   ```es tun. Nun habe ich aber intern die Information bekommen, dass es nicht möglich ist. Etwas```<br>
   ```anderes kann ich Ihnen dazu leider nicht sagen.```<br>
   ```...```<br>
   <br>
   Dann macht es halt möglich!!1<br>
   Hiervon unabhängig erfuhr AVM [vs. Cybits](https://www.heise.de/newsticker/meldung/AVM-vs-Cybits-Gericht-staerkt-GPL-1389738.html) bereits leidlich, dass die [Bedingungen der GPL nicht optional](https://gpl-violations.org/news/20110620-avm-cybits/) sind.<br>

 * __2020-06-12__<br>
   AVM verweigert die Herausgabe von Sourcecode aufgrund "Verjährung".<br>
   Dies betrifft die 7369 für die aktuell es nur ein [unvollständiges Quellpaket](https://web.archive.org/web/20200701201542/http://osp.avm.de/fritzbox/fritzbox-7369/) dem [wichtige Dateien fehlen](https://www.ip-phone-forum.de/threads/306749) gibt.<br>
   <br>
   AVM schrieb dazu auf eine Anfrage per Mail:<br>
   ```...```<br>
   ```Leider sieht es so aus, als könnten wir Ihnen in dieser Angelegenheit keine Lösung anbieten.```<br>
   ```Intern wurde nämlich nochmal drauf gesehen und festgestellt, dass das vermutlich auch weiterhin```<br>
   ```ein Problem werden wird zu kompilieren. Ausserdem haben die Kollegen festgestellt und bitten```<br>
   ```um Verständnis, dass GPL drei Jahre nach Produkteinstellung seine Wirkung verliert.```<br>
   ```Leider kann ich Ihnen daher keine weiteren Fragen zum Quellpaket der seit 2016 nicht mehr im```<br>
   ```Verkauf befindlichen 7369 beantworten. Ich wünsche Ihnen dennoch viel Erfolg mit Ihrem Projekt!```<br>
   ```...```<br>
   <br>
   Tatsache dagegen ist, dass die neueste Firmware '119.06.32' vom [11.10.2017](http://web.archive.org/web/20200701223436/https://download.avm.de/fritzbox/fritzbox-7369/other/fritz.os/) stammt und KEINE 3 Jahre alt ist!<br>
   Desweiteren ist die 7369 [weder als EOM noch als EOS](https://web.archive.org/web/20200624140752/https://avm.de/service/ende-des-produktsupports-und-der-produktweiterentwicklung/fritzbox/) gelistet.<br>
   Also bitte AVM: Nachbessern!<br>

 * __2020-05-12__<br>
   ~~Wer kann Freetz-NG einen Mirror-Server zur Verfügung stellen?<br>
   Zugriff: Download via http, am besten https<br>
   Speicherplatz: Maximal 10GB notwendig<br>
   Traffic: Unbekannt, am besten unbegrenzt<br>
   Upload: Entweder mittels FTP oder GIT vom [dl-mirror](https://github.com/Freetz-NG/dl-mirror)<br>
   Kontakt: Hier ein Issue öffnen oder PM im Forum~~<br>

 * __2020-05-05__<br>
   Mit ```LIBCTEST``` gekennzeichnete Geräte und/oder Firmware ist EXPERIMENTAL!<br>
   Es können zB Problemen mit der Benutzerverwaltung in ```/etc/passwd``` auftreten.<br>
   In diesem Fall lädt ```modusers load``` die Freetz-Konfiguration wieder.<br>
   Es gibt 4 neue Geräte: 6591 6660 7581 7582<br>
   Und 10 Laborversionen: 1200 1750 2400 3000 6490 6590 6591 7490 7530 7590<br>
   Siehe [r16706](https://trac.boxmatrix.info/freetz-ng/changeset/16706/freetz-ng)
   / [6607e747](https://github.com/Freetz-NG/freetz-ng/commit/6607e747bf9214db24a417aafd8a962f360d8ffc)<br>

 * __2020-05-04__<br>
   BusyBox 1.31 ist nun die Standardversion.<br>
   Diese Version ist für Firmware mit Kernel 2.6 nicht verfügbar.<br>
   Siehe [r16708](https://trac.boxmatrix.info/freetz-ng/changeset/16708/freetz-ng)
   / [8ebedc0c](https://github.com/Freetz-NG/freetz-ng/commit/8ebedc0c292f23889b487cbcedc074c791253944)<br>

 * __2020-04-17__<br>
   Patch [multiple fax pages](patches/README.md#patch-faxpages) hinzugefügt.<br>
   Mit diesem Patch können mehrere Seiten in einem Fax verschickt werden.<br>
   Siehe [r16674](https://trac.boxmatrix.info/freetz-ng/changeset/16674/freetz-ng)
   / [44ab5583](https://github.com/Freetz-NG/freetz-ng/commit/44ab55837827ac991284708ed34fafa2b8e84783)<br>

 * __2020-03-09__<br>
   Auf der Hauptseite des Webinterfaces werden nun zusätzlich der ```Temporäre```<br>
   ```Speicher``` und die ```Konfigurationspartition``` (falls verfügbar) angezeigt.<br>
   Dies kann im Webinterface unter ```Freetz > Weboberfläche``` konfiguriert werden.<br>
   Siehe [r16637](https://trac.boxmatrix.info/freetz-ng/changeset/16637/freetz-ng)
   / [76b57af6](https://github.com/Freetz-NG/freetz-ng/commit/76b57af63447928e84b5fe11adc0e1e5c854bad8)<br>

 * __2020-03-05__<br>
   Neuer Branch [libctest](https://github.com/Freetz-NG/freetz-ng/tree/libctest).<br>
   In diesem Branch können verschieden Geräte und Firmware getestet werden, die diese<br>
   libc nutzen: uclibc 1.0.30, uclibc 1.0.31, glib 2.23, glibc 2.28 und musl libc 1.1.24<br>
   Bekannte Probleme in der [README](https://github.com/Freetz-NG/freetz-ng/blob/libctest/README.md) beachten!<br>
   Siehe [4b64a268](https://github.com/Freetz-NG/freetz-ng/commit/4b64a268c688875dacf0c9089ff89299277d6b55)<br>

 * __2020-03-03__<br>
   Patch [web menu secure message](patches/README.md#patch-secure) hinzugefügt.<br>
   Der Patch entfernt dein Hinweis auf der Hauptseite bei unsicheren Einstellungen.<br>
   Dies betrifft aktuell ```IP-Phone von Aussen``` und ```2-Faktor deaktiviert```.<br>
   Siehe [r16610](https://trac.boxmatrix.info/freetz-ng/changeset/16610/freetz-ng)
   / [a7a60102](https://github.com/Freetz-NG/freetz-ng/commit/a7a60102d4a6fbb2739f9c5d09d9ab87bb1615c6)<br>

 * __2020-02-02__<br>
   Der neue Link ```/ftp``` zeigt immer auf das Verzeichnis ```/var/media/ftp/```.<br>
   Siehe [r16542](https://trac.boxmatrix.info/freetz-ng/changeset/16542/freetz-ng)
   / [dfeeec6d](https://github.com/Freetz-NG/freetz-ng/commit/dfeeec6d00066b5877c71a8d7ecabc9b3586e863)<br>

 * __2020-01-31__<br>
   Standard GID der ```users``` zu ```80``` geändert.<br>
   Dies sollte keine Auswirkungen auf bestehende Konfigurationen haben.<br>
   Die vorherige GID ```1``` wird von AVM für ```watchdog``` verwendet.<br>
   Siehe [r16534](https://trac.boxmatrix.info/freetz-ng/changeset/16534/freetz-ng)
   / [78a39a9d](https://github.com/Freetz-NG/freetz-ng/commit/78a39a9d9067ccf79c19e44c54a9b7a890d155cd)<br>

 * __2020-01-30__<br>
   Freetz-NG hat Geburtstag!<br>
   Ein erfolgreiches Jahr unter dem Motto: Mehr Features - weniger Bugs.<br>
   Siehe [r15015](https://trac.boxmatrix.info/freetz-ng/changeset/15015/freetz-ng)
   / [eaf06dbb](https://github.com/Freetz-NG/freetz-ng/commit/eaf06dbb153d8ee2eabeedb827f1c8d80e409744)<br>

 * __2020-01-19__<br>
   Compilierfehler beim Kernel für 7490 etc.<br>
   Dies kann durch einen nicht angewendeten Patch auftreten.<br>
   Zum beheben reicht ```make kernel-dirclean``` aus.<br>
   Siehe [r16472](https://trac.boxmatrix.info/freetz-ng/changeset/16472/freetz-ng)
   / [4421b48d](https://github.com/Freetz-NG/freetz-ng/commit/4421b48d92022fa9e15d50edd3384dbe6089111b)<br>
   Siehe [r16464](https://trac.boxmatrix.info/freetz-ng/changeset/16464/freetz-ng)
   / [66c33a0a](https://github.com/Freetz-NG/freetz-ng/commit/66c33a0a9e2c945a9ff70a7f527819402b6073e7)<br>
   Siehe [r16459](https://trac.boxmatrix.info/freetz-ng/changeset/16459/freetz-ng)
   / [fcf48be8](https://github.com/Freetz-NG/freetz-ng/commit/fcf48be8ff4385f5bfb264b96ee61c3d903d28ef)<br>

 * __2019-12-11__<br>
   FRITZ!Box 6591 Cable Support.<br>
   Images für dieses Gerät können nun gebaut werden, sind aber noch nicht lauffähig.<br>
   Den aktuellen Status kann man [FIRMWARES](FIRMWARES.md#not-supported-devices) entnehmen.<br>
   Siehe [r16424](https://trac.boxmatrix.info/freetz-ng/changeset/16424/freetz-ng)
   / [2c56b535](https://github.com/Freetz-NG/freetz-ng/commit/2c56b5354f0e2aa06d87ab7c6aedd70b639be08e)<br>

 * __2019-11-06__<br>
   Das Trac auf boxmatrix funktioniert aktuell nicht richtig.<br>
   Bitte stattdessen [Github](https://github.com/Freetz-NG/freetz-ng/issues) verwenden.<br>

 * __2019-11-03__<br>
   In [./docs](./) liegt nun die gesammte Dokumentation und das alte Wiki.<br>
   Darauf kann über die [README.md](README.md) oder [https://freetz-ng.github.io/](https://freetz-ng.github.io/) zugegriffen werden.<br>
   Nach einem Checkout sind die docs nun auch offline lesbar und passen immer zum aktuellen Revisionsstand.<br>

 * __2019-11-01__<br>
   Package [AVM-portfw](make/avm-portfw.md) hinzugefügt.<br>
   Damit können Ports auf die Fritzbox selbst freigegeben werden.<br>
   Falls vorher [AVM-rules (deprecated)](make/avm-rules.md) verwendet wurde, sollten in diesem zuerst die Freigaben gelöscht werden!<br>
   Ein Port kann nur mit einem Package freigegeben werden.<br>
   Siehe [r16331](https://trac.boxmatrix.info/freetz-ng/changeset/16331/freetz-ng)
   / [e1b77975](https://github.com/Freetz-NG/freetz-ng/commit/e1b77975a25a939ca935ce324b3d90f27d3013ba)<br>

 * __2019-10-27__<br>
   BusyBox auf Version 1.31.1 aktualisiert.<br>
   Falls diese genutzt werden soll, muss sie ausgewählt werden - auch wenn vorher bereits die 1.30.0 genutzt wurde!<br>
   Siehe [r16311](https://trac.boxmatrix.info/freetz-ng/changeset/16311/freetz-ng)
   / [6f93fa14](https://github.com/Freetz-NG/freetz-ng/commit/6f93fa14d35e709c09467b4fd450575094beeeb2)<br>

 * __2019-10-06__<br>
   Patch [udevmount](patches/README.md#patch-udevmount) hinzugefügt.<br>
   Dies ist der Nachfolger von [FREETZMOUNT](patches/README.md#patch-freetzmount) und unterstützt udev.<br>
   Siehe [r16207](https://trac.boxmatrix.info/freetz-ng/changeset/16207/freetz-ng)
   / [0b6eefe0](https://github.com/Freetz-NG/freetz-ng/commit/0b6eefe0091040bf0bf51245bc08446656f21a12)<br>

 * __2019-09-20__<br>
   Busybox Version 1.31.0 hinzugefügt.<br>
   Falls diese verwendet werden soll, muss sie im ```menuconfig``` ausgewählt werden.<br>
   Nicht verfügbar für Geräte mit altem 2.6 Kernel.<br>
   Siehe [r16118](https://trac.boxmatrix.info/freetz-ng/changeset/16118/freetz-ng)
   / [27b492b7](https://github.com/Freetz-NG/freetz-ng/commit/27b492b7c2471de6e8013fe5bed35508076e37d7)<br>

 * __2019-09-17__<br>
   Package [Dehydrated](make/dehydrated.md) (ursprünglich LetsEncrypt) hinzugefügt.<br>
   Dieses kann zusammen mit Lightpd HTTPS-Zertifikate generieren und verwenden.<br>
   Siehe [r16103](https://trac.boxmatrix.info/freetz-ng/changeset/16103/freetz-ng)
   / [084f67df](https://github.com/Freetz-NG/freetz-ng/commit/084f67df21b53a34cfddb9a12ccd84cf850e61b9)<br>
   Siehe [r15110](https://trac.boxmatrix.info/freetz-ng/changeset/15110/freetz-ng)
   / [1386ec4b](https://github.com/Freetz-NG/freetz-ng/commit/1386ec4bdf9d3ace1d92410218e2a949c73aa85d)<br>

 * __2019-09-16__<br>
   Package [minisatip](make/minisatip.md) hinzugefügt.<br>
   Dies kann die DVB-c Tuner von AVM Geräten als normales SAT>IP bereitstellen.<br>
   Siehe [r16090](https://trac.boxmatrix.info/freetz-ng/changeset/16090/freetz-ng)
   / [8f8a081e](https://github.com/Freetz-NG/freetz-ng/commit/8f8a081e32a2e8c936558ea0247eaf7b99312c8b)<br>

 * __2019-09-12__<br>
   Package [Addhole](make/addhole.md) hinzugefügt.<br>
   Dieses lädt Hostlisten herunter und blockiert sie mit Dnsmasq.<br>
   Siehe [r16055](https://trac.boxmatrix.info/freetz-ng/changeset/16055/freetz-ng)
   / [d1b88097](https://github.com/Freetz-NG/freetz-ng/commit/d1b8809796f3dfecae95c3c76f3fdf921a72cd32)<br>

 * __2019-09-06__<br>
   Patch [start-wlan-if-on-boot](patches/README.md#patch-start-wlan-if-on-boot) hinzugefügt.<br>
   Workaround für Probleme mit Wlan und DHCP auf VR9 Geräten wie 7490.<br>
   Siehe [r16031](https://trac.boxmatrix.info/freetz-ng/changeset/16031/freetz-ng)
   / [9f1eec67](https://github.com/Freetz-NG/freetz-ng/commit/9f1eec67f7cad2824fb4306020964aed9e8c00fe)<br>

 * __2019-08-25__<br>
   ```tools/push_firmware```: Alle Parameters sind nun optional.<br>
   Siehe [r15987](https://trac.boxmatrix.info/freetz-ng/changeset/15987/freetz-ng)
   / [f5433ffc](https://github.com/Freetz-NG/freetz-ng/commit/f5433ffc7ad3ab453382ba377c0206ef350d4a26)<br>

 * __2019-08-13__<br>
   Patch [add-telnetd](patches/README.md#add-telnetd) hinzugefügt.<br>
   Dies betrifft nur neuere Geräte und ist standardmässig deaktiviert.<br>
   Siehe [r15937](https://trac.boxmatrix.info/freetz-ng/changeset/15937/freetz-ng)
   / [3a818412](https://github.com/Freetz-NG/freetz-ng/commit/3a8184127e24c266d28413eb4633a25ddd079252)<br>

 * __2019-08-13__<br>
   Patch [remove-telnetd](patches/README.md#remove-telnetd) hinzugefügt.<br>
   Dies betrifft nur ältere Geräte und ist standardmässig aktiviert.<br>
   Siehe [r15931](https://trac.boxmatrix.info/freetz-ng/changeset/15931/freetz-ng)
   / [4e05ae21](https://github.com/Freetz-NG/freetz-ng/commit/4e05ae21279a6cff2a914c60904290a8674ecfff)<br>

 * __2019-08-03__<br>
   Freetz-Webui: Das Sicherheitslevel ist nun standardmässig '0', kann im menuconfig geändert werden.<br>
   Siehe [r15874](https://trac.boxmatrix.info/freetz-ng/changeset/15874/freetz-ng)
   / [a2f55ca4](https://github.com/Freetz-NG/freetz-ng/commit/a2f55ca4bb5ef2e1f66e2800fb1cd08a05c19004)<br>

 * __2019-07-31__<br>
   Addons: Es können nun ```./addon/*.pkg``` zum aktivieren von Addons verwendet werden.<br>
   Siehe [r15856](https://trac.boxmatrix.info/freetz-ng/changeset/15856/freetz-ng)
   / [3dda6456](https://github.com/Freetz-NG/freetz-ng/commit/3dda64565e9f58f35c310455fbc2e61a4b095ddc)<br>

 * __2019-06-22__<br>
   Package [LCD4linux](make/lcd4linux.md) hinzugefügt.<br>
   Damit kann ein USB-Display angesteuert werden.<br>
   Siehe [r15768](https://trac.boxmatrix.info/freetz-ng/changeset/15768/freetz-ng)
   / [a59ff246](https://github.com/Freetz-NG/freetz-ng/commit/a59ff246fc55a1c438723a404bf73afda8a6e7a1)<br>

 * __2019-06-12__<br>
   Patch [add-swapoptions](patches/README.md#add-swapoptions) hinzugefügt.<br>
   Die Swap-Optionen sind nun optional und standardmässig deaktiviert.<br>
   Siehe [r15727](https://trac.boxmatrix.info/freetz-ng/changeset/15727/freetz-ng)
   / [fcca7109](https://github.com/Freetz-NG/freetz-ng/commit/fcca7109eaae438d88e519bd63232d8e203b3d64)<br>

 * __2019-05-09__<br>
   Patch [drop-noexec](patches/README.md#drop-noexec-external) hinzugefügt.<br>
   Wenn auf dem USB Speicher Dateien ausgeführt werden sollen (external), muss dieser ausgewählt werden.<br>
   Siehe [r15530](https://trac.boxmatrix.info/freetz-ng/changeset/15530/freetz-ng)
   / [dcbd4885](https://github.com/Freetz-NG/freetz-ng/commit/dcbd4885dea3ee8ef7a15a54ecd852ce913a0492)<br>
   Siehe [r15505](https://trac.boxmatrix.info/freetz-ng/changeset/15505/freetz-ng)
   / [8f331457](https://github.com/Freetz-NG/freetz-ng/commit/8f3314576395b855356a7515ce86e4ceb13414a9)<br>

 * __2019-04-15__<br>
   Das Downloadverzeichnis ```./dl``` ist nun ein Link.<br>
   Dieser verweiset auf ```~/.freetz-dl``` wodurch mehrere Checkouts sich das gleiche Verzeichis teilen.<br>
   Wem dies nicht gefällt kann den Link durch ein Verzeichnis ersetzen.<br>
   Siehe [r15411](https://trac.boxmatrix.info/freetz-ng/changeset/15411/freetz-ng)
   / [0c7fafc8](https://github.com/Freetz-NG/freetz-ng/commit/0c7fafc8ee4b980c89aece585a196b38cff579c6)<br>

 * __2019-04-02__<br>
   Package [ProxyChains-NG](make/proxychains-ng.md) hinzugefügt.<br>
   Damit kann jedes Programm einen Proxy verwenden.<br>
   Siehe [r15112](https://trac.boxmatrix.info/freetz-ng/changeset/15112/freetz-ng)
   / [d8f65059](https://github.com/Freetz-NG/freetz-ng/commit/d8f65059f28ff8f22332efb73059e6ae7d21f04c)<br>

 * __2019-03-12__<br>
   Änderung bei der Signierung von Images.<br>
   Der private Schlüssel wird in ```./.signature``` abgelegt. Dies ist ein Link auf ```~/.freetz-signature```.<br>
   Damit nutzt jeder Checkout den gleichen Schlüssel und benötigt das gleiche Passwort.<br>
   Wem dies nicht gefällt kann den Link durch ein Verzeichnis ersetzen.<br>
   Siehe [r15300](https://trac.boxmatrix.info/freetz-ng/changeset/15300/freetz-ng)
   / [c3437a4e](https://github.com/Freetz-NG/freetz-ng/commit/c3437a4eb47bcefa209aefa67d77b9de606c4676)<br>

 * __2019-03-08__<br>
   Signaturprüfung von AVM-Images beim _Entpacken_.<br>
   Bislang wurde die Firmware nach dem _Download_ mittel MD5 geprüft.<br>
   Dies hatte den Nachteil dass eine Dateien die manuell nach dl/fw/ kopiert wurden nicht geprüft wurden.<br>
   Man kann die Signatur auch manuell mit ```fwmod -v $key $img``` prüfen.<br>
   Hinweis: Die allerersten AVM Geräte nutzten noch keine Signatur und werden weiterhin via MD5 geprüft.<br>
   Siehe [r15284](https://trac.boxmatrix.info/freetz-ng/changeset/15284/freetz-ng)
   / [be2994f7](https://github.com/Freetz-NG/freetz-ng/commit/be2994f7e61c3168617905e665462569d9110b71)<br>

 * __2019-02-04__<br>
   Package [CA-bundle](make/ca-bundle.md) (ursprünglich CAbundle) hinzugefügt.<br>
   Damit können wget, curl usw HTTPS-Zertifikate prüfen.<br>
   Siehe [r15109](https://trac.boxmatrix.info/freetz-ng/changeset/15109/freetz-ng)
   / [3b38f82c](https://github.com/Freetz-NG/freetz-ng/commit/3b38f82c7b5beebe35696c7c3de9aad1d8296e8d)<br>

 * __2019-02-19__<br>
   Freetz-Webui: Option "Downgrade" des Firmware-Updates repariert.<br>
   Nach einem Downgrade sollte man die Einstellungen zurücksetzen oder ein Backup einspielen.<br>
   Siehe [r15190](https://trac.boxmatrix.info/freetz-ng/changeset/15190/freetz-ng)
   / [f300b9a7](https://github.com/Freetz-NG/freetz-ng/commit/f300b9a71754d98a56e6794770269cb63142fc60)<br>

 * __2019-02-04__<br>
   Patch [modify-dsl-dettings](patches/MODIFY_DSL_SETTINGS.md) hinzugefügt.<br>
   Mit diesem Patch wird die DSL Störsicherheit um 4 Performance-Stufen erweitert.<br>
   Siehe [r15100](https://trac.boxmatrix.info/freetz-ng/changeset/15100/freetz-ng)
   / [09aae63e](https://github.com/Freetz-NG/freetz-ng/commit/09aae63ee888ea4d3cbe38d0ef9990a73e04bf31)<br>
   Siehe [r15119](https://trac.boxmatrix.info/freetz-ng/changeset/15119/freetz-ng)
   / [262d8a9e](https://github.com/Freetz-NG/freetz-ng/commit/262d8a9ee9dc8c05dda60974b93ce531c91194f2)<br>

 * __2019-02-04__<br>
   Patch [modify-counter](patches/MODIFY_COUNTER.md) hinzugefügt.<br>
   Mit diesem Patch wird der Online-Zähler von AVM verändert, es werden Gigabyte und Tage engezeigt.<br>
   Siehe [r15099](https://trac.boxmatrix.info/freetz-ng/changeset/15099/freetz-ng)
   / [e6d16b75](https://github.com/Freetz-NG/freetz-ng/commit/e6d16b75436fdb8322434b5e380ae5e05d9ec604)<br>
   Siehe [r15119](https://trac.boxmatrix.info/freetz-ng/changeset/15119/freetz-ng)
   / [262d8a9e](https://github.com/Freetz-NG/freetz-ng/commit/262d8a9ee9dc8c05dda60974b93ce531c91194f2)<br>

 * __2019-02-01__<br>
   Freetz-Webui: Hostname im Seitentitel.<br>
   Es wird der Hostname ohne Domain angezeigt, falls er verändert wurde.<br>
   Diesen kann man in der ar7.cfg mit Domain oder im AVM-Webui unter "Fritz!Box-Name" setzen.<br>
   Siehe [r15073](https://trac.boxmatrix.info/freetz-ng/changeset/15073/freetz-ng)
   / [f97f6679](https://github.com/Freetz-NG/freetz-ng/commit/f97f66795b1a4de2e67ec8f92d646c820674ff1b)<br>
   Siehe [r15743](https://trac.boxmatrix.info/freetz-ng/changeset/15743/freetz-ng)
   / [9bf028d7](https://github.com/Freetz-NG/freetz-ng/commit/9bf028d7425c18fabe689b3ae27658718169c892)<br>

 * __2019-02-01__<br>
   Skin [cuma](themes/skin.md#cuma) (dark) hinzugefügt.<br>
   Siehe [r15071](https://trac.boxmatrix.info/freetz-ng/changeset/15071/freetz-ng)
   / [bebcd72a](https://github.com/Freetz-NG/freetz-ng/commit/bebcd72a13140e137d56374035081b18de2a9567)<br>

