# Remove CAPIoverTCP
Entfernt CapiOverTCP-Schnittstelle der FritzBox.
Achtung! CapiOverTCP wird von mehreren nützlichen PC-Programmen für den Zugriff auf die Box benutzt!
FritzFax nutzt z.B. diese Schnittstelle, um Faxe von PC aus über die FritzBox zu verschicken.<br>
<br>

Dieser Patch entfernt das Binary "capiotcpserver" (Größe 13 KB) aus der Firmware. Dieses Binary lauscht normalerweise auf Port 5031.

### CapiOverIP unter Windows

Unter Windows wird CapiOverIP u.a. benutzt von:

 * FritzFax
 * OutLook Wählhilfe (zum Zugriff auf die die FritzBox)
 * ​[isplayCall](http://www.lachenmann-net.de/displaycall/)
 * [Phoner](http://www.phoner.de/)

### CapiOverIP unter Linux

Auch unter Linux lässt sich das CapiOverTCP nutzen, wie es ​dieses [Howto](http://wiki.ip-phone-forum.de/gateways:avm:howtos:mods:remotecapi) beschreibt, und zwar z.B. zum

 * Faxe versenden und empfangen mithilfe eines Soft-DSP
 * Telefonieren mit Headset
 * Verbinden mit Asterisk 

### CapiOverIP auf dem Mac

Wenn hier jemand was weiß, bitte eintragen!
Weiterführende Links

 * [​CapiOverTCP im Fritzbox-Wiki](http://www.wehavemorefun.de/fritzbox/Nutzung_des_Capi-over-TCP_Server_der_Fritzbox)
 * ​[AVM FAQ zu Fritz!Fax](http://www.avm.de/de/Service/FAQs/FAQ_Sammlung/11843.php3)
 * ​[a-sa Wiki: Faxen über die Fritz!Box](http://a-sawicki.de/cms/index.php?option=com_content&task=view&id=38&Itemid=29)
 * ​[Howto: CapiOverIp unter Linux](http://wiki.ip-phone-forum.de/gateways:avm:howtos:mods:remotecapi)

