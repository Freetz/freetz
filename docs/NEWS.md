# NEWS

 * __2020-01-19__<br>
   Compilierfehler beim Kernel für 7490 etc.<br>
   Dies kann durch einen nicht angewendeten Patch auftreten.<br>
   Zum beheben reicht ```make kernel-dirclean``` aus.<br>
   Siehe [r16472](https://trac.boxmatrix.info/freetz-ng/changeset/16472/freetz-ng) / 4421b48d92022fa9e15d50edd3384dbe6089111b<br>
   Siehe [r16464](https://trac.boxmatrix.info/freetz-ng/changeset/16464/freetz-ng) / 66c33a0a9e2c945a9ff70a7f527819402b6073e7<br>
   Siehe [r16459](https://trac.boxmatrix.info/freetz-ng/changeset/16459/freetz-ng) / fcf48be8ff4385f5bfb264b96ee61c3d903d28ef<br>

 * __2019-12-11__<br>
   FRITZ!Box 6591 Cable Support.<br>
   Images für dieses Gerät können nun gebaut werden, sind aber noch nicht lauffähig.<br>
   Den aktuellen Status kann man [FIRMWARES](FIRMWARES.md#not-supported-devices) entnehmen.<br>
   Siehe [r16424](https://trac.boxmatrix.info/freetz-ng/changeset/16424/freetz-ng) / 2c56b5354f0e2aa06d87ab7c6aedd70b639be08e <br>

 * __2019-11-06__<br>
   Das Trac auf boxmatrix funktioniert aktuell nicht richtig.<br>
   Bitte stattdessen das [DEB](https://www.digital-eliteboard.com/forums/2045/) oder [Github](https://github.com/Freetz-NG/freetz-ng/issues) verwenden.<br>

 * __2019-11-03__<br>
   In [./docs](./) liegt nun die gesammte Dokumentation und das alte Wiki.<br>
   Darauf kann über die [README.md](README.md) oder [https://freetz-ng.github.io/](https://freetz-ng.github.io/) zugegriffen werden.<br>
   Nach einem Checkout sind die docs nun auch offline lesbar und passen immer zum aktuellen Revisionsstand.<br>

 * __2019-11-01__<br>
   Package [AVM-portfw](make/avm-portfw.md) hinzugefügt.<br>
   Damit können Ports auf die Fritzbox selbst freigegeben werden.<br>
   Falls vorher [AVM-rules (deprecated)](make/avm-rules.md) verwendet wurde, sollten in diesem zuerst die Freigaben gelöscht werden!<br>
   Ein Port kann nur mit einem Package freigegeben werden.<br>
   Siehe [r16331](https://trac.boxmatrix.info/freetz-ng/changeset/16331/freetz-ng) / e1b77975a25a939ca935ce324b3d90f27d3013ba<br>

 * __2019-10-27__<br>
   BusyBox auf Version 1.31.1 aktualisiert.<br>
   Falls diese genutzt werden soll, muss sie ausgewählt werden - auch wenn vorher bereits die 1.30.0 genutzt wurde!<br>
   Siehe [r16311](https://trac.boxmatrix.info/freetz-ng/changeset/16311/freetz-ng) / 6f93fa14d35e709c09467b4fd450575094beeeb2<br>

 * __2019-10-06__<br>
   Patch [udevmount](patches/README.md#patch-udevmount) hinzugefügt.<br>
   Dies ist der Nachfolger von [FREETZMOUNT](patches/README.md#patch-freetzmount) und unterstützt udev.<br>
   Siehe [r16207](https://trac.boxmatrix.info/freetz-ng/changeset/16207/freetz-ng) / 0b6eefe0091040bf0bf51245bc08446656f21a12<br>

 * __2019-09-20__<br>
   Busybox Version 1.31.0 hinzugefügt.<br>
   Falls diese verwendet werden soll, muss sie im ```menuconfig``` ausgewählt werden.<br>
   Nicht verfügbar für Geräte mit altem 2.6 Kernel.<br>
   Siehe [r16118](https://trac.boxmatrix.info/freetz-ng/changeset/16118/freetz-ng) / 27b492b7c2471de6e8013fe5bed35508076e37d7<br>

 * __2019-09-17__<br>
   Package [Dehydrated](make/dehydrated.md) (ursprünglich LetsEncrypt) hinzugefügt.<br>
   Dieses kann zusammen mit Lightpd HTTPS-Zertifikate generieren und verwenden.<br>
   Siehe [r16103](https://trac.boxmatrix.info/freetz-ng/changeset/16103/freetz-ng) / 084f67df21b53a34cfddb9a12ccd84cf850e61b9<br>
   Siehe [r15110](https://trac.boxmatrix.info/freetz-ng/changeset/15110/freetz-ng) / 1386ec4bdf9d3ace1d92410218e2a949c73aa85d<br>

 * __2019-09-16__<br>
   Package [minisatip](make/minisatip.md) hinzugefügt.<br>
   Dies kann die DVB-c Tuner von AVM Geräten als normales SAT>IP bereitstellen.<br>
   Siehe [r16090](https://trac.boxmatrix.info/freetz-ng/changeset/16090/freetz-ng) / 8f8a081e32a2e8c936558ea0247eaf7b99312c8b<br>

 * __2019-09-12__<br>
   Package [Addhole](make/addhole.md) hinzugefügt.<br>
   Dieses lädt Hostlisten herunter und blockiert sie mit Dnsmasq.<br>
   Siehe [r16055](https://trac.boxmatrix.info/freetz-ng/changeset/16055/freetz-ng) / d1b8809796f3dfecae95c3c76f3fdf921a72cd32<br>

 * __2019-09-06__<br>
   Patch [start-wlan-if-on-boot](patches/README.md#patch-start-wlan-if-on-boot) hinzugefügt.<br>
   Workaround für Probleme mit Wlan und DHCP auf VR9 Geräten wie 7490.<br>
   Siehe [r16031](https://trac.boxmatrix.info/freetz-ng/changeset/16031/freetz-ng) / 9f1eec67f7cad2824fb4306020964aed9e8c00fe<br>

 * __2019-08-25__<br>
   ```tools/push_firmware```: Alle Parameters sind nun optional.<br>
   Siehe [r15987](https://trac.boxmatrix.info/freetz-ng/changeset/15987/freetz-ng) / f5433ffc7ad3ab453382ba377c0206ef350d4a26<br>

 * __2019-08-13__<br>
   Patch [add-telnetd](patches/README.md#add-telnetd) hinzugefügt.<br>
   Dies betrifft nur neuere Geräte und ist standardmässig deaktiviert.<br>
   Siehe [r15937](https://trac.boxmatrix.info/freetz-ng/changeset/15937/freetz-ng) / 3a8184127e24c266d28413eb4633a25ddd079252<br>

 * __2019-08-13__<br>
   Patch [remove-telnetd](patches/README.md#remove-telnetd) hinzugefügt.<br>
   Dies betrifft nur ältere Geräte und ist standardmässig aktiviert.<br>
   Siehe [r15931](https://trac.boxmatrix.info/freetz-ng/changeset/15931/freetz-ng) / 4e05ae21279a6cff2a914c60904290a8674ecfff<br>

 * __2019-08-03__<br>
   Freetz-Webui: Das Sicherheitslevel ist nun standardmässig '0', kann im menuconfig geändert werden.<br>
   Siehe [r15874](https://trac.boxmatrix.info/freetz-ng/changeset/15874/freetz-ng) / a2f55ca4bb5ef2e1f66e2800fb1cd08a05c19004<br>

 * __2019-07-31__<br>
   Addons: Es können nun ```./addon/*.pkg``` zum aktivieren von Addons verwendet werden.<br>
   Siehe [r15856](https://trac.boxmatrix.info/freetz-ng/changeset/15856/freetz-ng) / 3dda64565e9f58f35c310455fbc2e61a4b095ddc<br>

 * __2019-06-22__<br>
   Package [LCD4linux](make/lcd4linux.md) hinzugefügt.<br>
   Damit kann ein USB-Display angesteuert werden.<br>
   Siehe [r15768](https://trac.boxmatrix.info/freetz-ng/changeset/15768/freetz-ng) / a59ff246fc55a1c438723a404bf73afda8a6e7a1<br>

 * __2019-06-12__<br>
   Patch [add-swapoptions](patches/README.md#add-swapoptions) hinzugefügt.<br>
   Die Swap-Optionen sind nun optional und standardmässig deaktiviert.<br>
   Siehe [r15727](https://trac.boxmatrix.info/freetz-ng/changeset/15727/freetz-ng) / fcca7109eaae438d88e519bd63232d8e203b3d64<br>

 * __2019-05-09__<br>
   Patch [drop-noexec](patches/README.md#drop-noexec-external) hinzugefügt.<br>
   Wenn auf dem USB Speicher Dateien ausgeführt werden sollen (external), muss dieser ausgewählt werden.<br>
   Siehe [r15530](https://trac.boxmatrix.info/freetz-ng/changeset/15530/freetz-ng) / dcbd4885dea3ee8ef7a15a54ecd852ce913a0492<br>
   Siehe [r15505](https://trac.boxmatrix.info/freetz-ng/changeset/15505/freetz-ng) / 8f3314576395b855356a7515ce86e4ceb13414a9<br>

 * __2019-04-15__<br>
   Das Downloadverzeichnis ```./dl``` ist nun ein Link.<br>
   Dieser verweiset auf ```~/.freetz-dl``` wodurch mehrere Checkouts sich das gleiche Verzeichis teilen.<br>
   Wem dies nicht gefällt kann den Link durch ein Verzeichnis ersetzen.<br>
   Siehe [r15411](https://trac.boxmatrix.info/freetz-ng/changeset/15411/freetz-ng) / 0c7fafc8ee4b980c89aece585a196b38cff579c6<br>

 * __2019-04-02__<br>
   Package [ProxyChains-NG](make/proxychains-ng.md) hinzugefügt.<br>
   Damit kann jedes Programm einen Proxy verwenden.<br>
   Siehe [r15112](https://trac.boxmatrix.info/freetz-ng/changeset/15112/freetz-ng) / d8f65059f28ff8f22332efb73059e6ae7d21f04c<br>

 * __2019-03-12__<br>
   Änderung bei der Signierung von Images.<br>
   Der private Schlüssel wird in ```./.signature``` abgelegt. Dies ist ein Link auf ```~/.freetz-signature```.<br>
   Damit nutzt jeder Checkout den gleichen Schlüssel und benötigt das gleiche Passwort.<br>
   Wem dies nicht gefällt kann den Link durch ein Verzeichnis ersetzen.<br>
   Siehe [r15300](https://trac.boxmatrix.info/freetz-ng/changeset/15300/freetz-ng) / c3437a4eb47bcefa209aefa67d77b9de606c4676<br>

 * __2019-03-08__<br>
   Signaturprüfung von AVM-Images beim _Entpacken_.<br>
   Bislang wurde die Firmware nach dem _Download_ mittel MD5 geprüft.<br>
   Dies hatte den Nachteil dass eine Dateien die manuell nach dl/fw/ kopiert wurden nicht geprüft wurden.<br>
   Man kann die Signatur auch manuell mit ```fwmod -v $key $img``` prüfen.<br>
   Hinweis: Die allerersten AVM Geräte nutzten noch keine Signatur und werden weiterhin via MD5 geprüft.<br>
   Siehe [r15284](https://trac.boxmatrix.info/freetz-ng/changeset/15284/freetz-ng) / be2994f7e61c3168617905e665462569d9110b71<br>

 * __2019-02-04__<br>
   Package [CA-bundle](make/ca-bundle.md) (ursprünglich CAbundle) hinzugefügt.<br>
   Damit können wget, curl usw HTTPS-Zertifikate prüfen.<br>
   Siehe [r15109](https://trac.boxmatrix.info/freetz-ng/changeset/15109/freetz-ng) / 3b38f82c7b5beebe35696c7c3de9aad1d8296e8d<br>

 * __2019-02-19__<br>
   Freetz-Webui: Option "Downgrade" des Firmware-Updates repariert.<br>
   Nach einem Downgrade sollte man die Einstellungen zurücksetzen oder ein Backup einspielen.<br>
   Siehe [r15190](https://trac.boxmatrix.info/freetz-ng/changeset/15190/freetz-ng) / f300b9a71754d98a56e6794770269cb63142fc60<br>

 * __2019-02-04__<br>
   Patch [modify-dsl-dettings](patches/MODIFY_DSL_SETTINGS.md) hinzugefügt.<br>
   Mit diesem Patch wird die DSL Störsicherheit um 4 Performance-Stufen erweitert.<br>
   Siehe [r15100](https://trac.boxmatrix.info/freetz-ng/changeset/15100/freetz-ng) / 09aae63ee888ea4d3cbe38d0ef9990a73e04bf31<br>
   Siehe [r15119](https://trac.boxmatrix.info/freetz-ng/changeset/15119/freetz-ng) / 262d8a9ee9dc8c05dda60974b93ce531c91194f2<br>

 * __2019-02-04__<br>
   Patch [modify-counter](patches/MODIFY_COUNTER.md) hinzugefügt.<br>
   Mit diesem Patch wird der Online-Zähler von AVM verändert, es werden Gigabyte und Tage engezeigt.<br>
   Siehe [r15099](https://trac.boxmatrix.info/freetz-ng/changeset/15099/freetz-ng) / e6d16b75436fdb8322434b5e380ae5e05d9ec604<br>
   Siehe [r15119](https://trac.boxmatrix.info/freetz-ng/changeset/15119/freetz-ng) / 262d8a9ee9dc8c05dda60974b93ce531c91194f2<br>

 * __2019-02-01__<br>
   Freetz-Webui: Hostname im Seitentitel.<br>
   Es wird der Hostname ohne Domain angezeigt, falls er verändert wurde.<br>
   Diesen kann man in der ar7.cfg mit Domain oder im AVM-Webui unter "Fritz!Box-Name" setzen.<br>
   Siehe [r15073](https://trac.boxmatrix.info/freetz-ng/changeset/15073/freetz-ng) / f97f66795b1a4de2e67ec8f92d646c820674ff1b<br>
   Siehe [r15743](https://trac.boxmatrix.info/freetz-ng/changeset/15743/freetz-ng) / 9bf028d7425c18fabe689b3ae27658718169c892<br>

 * __2019-02-01__<br>
   Skin [cuma](themes/skin.md#cuma) (dark) hinzugefügt.<br>
   Siehe [r15071](https://trac.boxmatrix.info/freetz-ng/changeset/15071/freetz-ng) / bebcd72a13140e137d56374035081b18de2a9567<br>

