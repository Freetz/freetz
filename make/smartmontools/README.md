# smartmontools 7.0

Mit den Smartmontools (bzw. mit smartctl) können die
"Gesundheitswerte" von Festplatten (auch
[SMART](http://smartmontools.sourceforge.net/man/smartctl.8.html)
genannt) ausgelesen, und im Freetz-Webinterface unter Status angezeigt
werden. Dies funktioniert allerdings nur dann, wenn die Festplatte und
dessen USB-Festplattengehäuse das Auslesen dieser Werte auch zuläßt.

[![Statusseite von SMART im WebIf](../../README/screenshots/244_md.png)](../../README/screenshots/244.png)

**Folgende Werte werden im Webinterface angezeigt:**

-   Modellbezeichnung der Festplatte und dessen Speicherkapazität.
-   Der allgemeine, von SMART bewertete Zustand (Health) der
    Festplatte.
-   Aktuelle Temperatur der Festplatte in °C.
-   Bisherige Laufzeit der Festplatte.
-   Anzahl der Einschaltvorgänge.
-   Und anschließend alle verfügbaren Werte, wie man sie auch auf der
    Konsole sehen würde.

**Hinweis:**
Durch das Öffnen der Statusseite im Webinterface wird eine eventuell
geparkte Festplatte hochgefahren! Daher kann es auch ein wenig dauern,
bis die Statusseite komplett angezeigt wird.

