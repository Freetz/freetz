# smstools3 3.1.21

[![SMStools3](../screenshots/251_md.jpg)](../screenshots/251.jpg)

Package um SMS mit einem UMTS-Stick zu versenden und zu empfangen.

 * Falls die
FritzBox UMTS-Unterstützung hat, am besten den umtsd herauspatchen.

SMStools3 kann komplett per Webif bedient werden oder alternativ per
Terminal.

### Datenverzeichnis

Das "Datenverzeichnis" legt man am besten auf einen USB-Stick, damit
keine SMS verloren gehen. Dennoch wird ein `modsave` beim Beenden des
Packages ausgeführt, falls der Pfad mit `/tmp/flash` beginnt.

### Senden und Empfangen mit dem Terminal

Eine SMS kann man diesem Befehl versendet werden, der Parameter `flash`
ist optional:

```
rc.smstools3 sendsms flash +497771234567 Text der Nachricht
```

Empfangene SMS können so aufgelistet angezeigt:

```
rc.smstools3 listsms
```

### Weiteres

-   Komplette Dokumentation:
    [http://smstools3.kekekasvi.com/](http://smstools3.kekekasvi.com/)
-   Falls der Stick nicht richtig erkannt wird, sondern nur als
    Datenträger:
    [wiki:/packages/ppp#Weiteres](ppp.html#Weiteres)
