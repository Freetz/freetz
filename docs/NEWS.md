# NEWS

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

 * __2019-04-02__<br>
   Package [ProxyChains-NG](make/proxychains-ng.md) hinzugefügt.<br>
   Damit kann jedes Programm einen Proxy verwenden.<br>
   Siehe [r15112](https://trac.boxmatrix.info/freetz-ng/changeset/15112/freetz-ng) / d8f65059f28ff8f22332efb73059e6ae7d21f04c<br>

 * __2019-02-04__<br>
   Package [CA-bundle](make/ca-bundle.md) (ursprünglich CAbundle) hinzugefügt.<br>
   Damit können wget, curl usw HTTPS-Zertifikate prüfen.<br>
   Siehe [r15109](https://trac.boxmatrix.info/freetz-ng/changeset/15109/freetz-ng) / 3b38f82c7b5beebe35696c7c3de9aad1d8296e8d<br>

 * __2019-02-19__<br>
   Freetz-Webui: Option "Downgrade" des Firmware-Updates repariert.<br>
   Nach einem Downgrade sollte man die Einstellungen zurücksetzen oder ein Backup einspielen.<br>
   Siehe [r15190](https://trac.boxmatrix.info/freetz-ng/changeset/15190/freetz-ng) / f300b9a71754d98a56e6794770269cb63142fc60<br>

 * __2019-02-01__<br>
   Skin [cuma](themes/skin.md#cuma) (dark) hinzugefügt.<br>
   Siehe [r15071](https://trac.boxmatrix.info/freetz-ng/changeset/15071/freetz-ng) / bebcd72a13140e137d56374035081b18de2a9567<br>

