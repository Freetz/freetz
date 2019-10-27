# Eigene Dateien in die Firmware integrieren

Die Fritzbox besitzt zwei Speicherbereiche:

1.  den Flash
2.  den Arbeitsspeicher (RAM)

Um im laufenden Betrieb Dateien anzulegen und zu verändern, lässt sich
das Verzeichnis `/tmp` nutzen. Es liegt im Arbeitsspeicher in einer
RAM-Disk und arbeitet wie ein normales beschreibbares Dateisystem.
Folgende Dinge sind jedoch zu beachten:

-   Es nutzt den vorhandenen Arbeitsspeicher mit, der je nach Box bis zu
    64MB gross ist. Wird die Menge der Daten im Arbeitsspeicher zu groß,
    startet die Box ohne Vorwarnung neu.
-   Alles, was im Arbeitsspeicher liegt, ist nach einem Reboot oder
    Stromausfall verloren.

Für die "feste Integration" gibt es mehrere Möglichkeiten:

```
+----------------------+----------------------+----------------------+
| Variante             | Pros                 | Contras              |
+======================+======================+======================+
| via Freetz Image     | -   einfaches        | -   die modifizierte |
|                      |     Handling         |     Firmware muss    |
|                      | -   keine bestehende |     geflasht werden  |
|                      |     Internetverbindu | -   der              |
|                      | ng                   |     Flash-Speicher   |
|                      |     erforderlich     |     ist kleiner als  |
|                      |                      |     das RAM und oft  |
|                      |                      |     eh schon fast    |
|                      |                      |     voll             |
+----------------------+----------------------+----------------------+
| via `debug.cfg`      | -   funktioniert auf | -   funktioniert nur |
|                      |     jeder Box        |     mit              |
|                      | -   keine bestehende |     ASCII-Dateien,   |
|                      |     Internetverbindu |     wie z.B. mit     |
|                      | ng                   |     Skripten oder    |
|                      |     erforderlich     |     Konfigurationsda |
|                      |                      | teien                |
|                      |                      | -   werden           |
|                      |                      |     Änderungen an    |
|                      |                      |     diesen Dateien   |
|                      |                      |     vorgenommen,     |
|                      |                      |     müssen diese     |
|                      |                      |     auch wieder in   |
|                      |                      |     die debug.cfg    |
|                      |                      |     übernommen       |
|                      |                      |     werden           |
+----------------------+----------------------+----------------------+
| Nachladen von        | -   funktioniert mit | -   bestehende       |
| Webserver            |     allen Dateien,   |     Internetverbindu |
|                      |     auch mit         | ng                   |
|                      |     binären.         |     oder laufender   |
|                      |     Notwendig z.B.   |     interner         |
|                      |     für nachgeladene |     Webserver        |
|                      |     Programme wie    |     erforderlich     |
|                      |     z.B. bFTP,       | -   private Dateien  |
|                      |     dropbear(SSH)    |     wie z.B. secret  |
|                      |     oder OpenVPN,    |     keys für SSH     |
|                      | -   funktioniert auf |     oder VPN dürfen  |
|                      |     jeder Box        |     keinesfalls im   |
|                      | -   Umgeht die       |     Web abgelegt     |
|                      |     Probleme des     |     werden! Wer dies |
|                      |     knappen          |     tut, kann sich   |
|                      |     Flash-Speichers  |     Verschlüsselung  |
|                      | -   Änderungen       |     gleich sparen.   |
|                      |     lassen sich      |                      |
|                      |     leicht am        |                      |
|                      |     Rechner mit dem  |                      |
|                      |     eigenen Editor   |                      |
|                      |     (z.B. TextPad)   |                      |
|                      |     vornehmen        |                      |
|                      |     (Achtung: Auf    |                      |
|                      |     UNIX-Formatierun |                      |
|                      | g                    |                      |
|                      |     achten!) und     |                      |
|                      |     dann auf den     |                      |
|                      |     Webspace         |                      |
|                      |     hochladen.       |                      |
|                      | -   wer mehrere      |                      |
|                      |     Fritz!Boxen oder |                      |
|                      |     Router hat, kann |                      |
|                      |     so auf einmal    |                      |
|                      |     die              |                      |
|                      |     Konfiguration    |                      |
|                      |     für alle         |                      |
|                      |     gleichzeitig     |                      |
|                      |     anpassen         |                      |
+----------------------+----------------------+----------------------+
| Nachladen vom USB    | -   funktioniert mit | -   funktioniert nur |
| Stick                |     allen Dateien,   |     bei vorhendenem  |
|                      |     auch mit         |     USB Slot mit     |
|                      |     binären.         |     einem USB Stick  |
|                      |     Notwendig z.B.   |     (bzw. anderem    |
|                      |     für nachgeladene |     USB              |
|                      |     Programme wie    |     Speichermedium)  |
|                      |     z.B. bFTP,       | -   Die USB devices  |
|                      |     dropbear(SSH)    |     werden, je nach  |
|                      |     oder OpenVPN,    |     Firmware, leider |
|                      | -   Umgeht die       |     unter            |
|                      |     Probleme des     |     verschiedenen    |
|                      |     knappen          |     Namen            |
|                      |     Flash-Speichers  |     eingebunden,     |
|                      | -   Änderungen       |     sodaß in der     |
|                      |     lassen sich      |     debug.cfg darau  |
|                      |     leicht am        |     eingegangen      |
|                      |     Rechner mit dem  |     werden muß.      |
|                      |     eigenen Editor   |                      |
|                      |     (z.B.            |                      |
|                      |     Notepadplus)     |                      |
|                      |     vornehmen        |                      |
+----------------------+----------------------+----------------------+
| WebDAV- bzw. NFS-    | -   RAM wird nicht   | -   bestehende       |
| Share mounten        |     mit lokalen      |     Internetverbindu |
|                      |     Kopien von       | ng                   |
|                      |     Dateien gefüllt  |     und              |
|                      |     (abgesehen von   |     WebDAV-Server    |
|                      |     der Ausführung)  |     (z.B. GMX/1&1    |
|                      | -   funktioniert mit |     MediaCenter)     |
|                      |     allen Dateien,   |     erforderlich     |
|                      |     auch mit binären | -   private Dateien  |
|                      | -   funktioniert auf |     wie z.B. secret  |
|                      |     jeder Box        |     keys für SSH     |
|                      | -   umgeht die       |     oder VPN dürfen  |
|                      |     Probleme des     |     keinesfalls im   |
|                      |     knappen          |     Web abgelegt     |
|                      |     Flash-Speichers  |     werden! Wer dies |
|                      | -   sehr             |     tut, kann sich   |
|                      |     komfortabel, da  |     Verschlüsselung  |
|                      |     kein Nachladen   |     gleich sparen.   |
|                      |     per debug.cfg    |                      |
|                      |     nötig ist        |                      |
|                      | -   Änderungen       |                      |
|                      |     lassen sich      |                      |
|                      |     leicht am        |                      |
|                      |     Rechner mit dem  |                      |
|                      |     eigenen Editor   |                      |
|                      |     (z.B. TextPad)   |                      |
|                      |     vornehmen        |                      |
|                      |     (Achtung: Auf    |                      |
|                      |     UNIX-Formatierun |                      |
|                      | g                    |                      |
|                      |     achten!) und     |                      |
|                      |     dann auf den     |                      |
|                      |     WebDAV-Share     |                      |
|                      |     hochladen.       |                      |
|                      | -   wer mehrere      |                      |
|                      |     Fritz!Boxen oder |                      |
|                      |     Router hat, kann |                      |
|                      |     so auf einmal    |                      |
|                      |     die              |                      |
|                      |     Konfiguration    |                      |
|                      |     für alle         |                      |
|                      |     gleichzeitig     |                      |
|                      |     anpassen         |                      |
+----------------------+----------------------+----------------------+
```

Die "perfekte Lösung" gibt es natürlich nicht. Je nach Anwendungsfall
werden die Möglichkeiten kombiniert.

### Feste Integration über das Freetz Image

-   Freetz-1.1.x: Die Datei kann unter `./root` an die gewünschte Stelle
    kopiert werden.
-   Ab Freetz-1.2: Dies kann ohne großen Aufwand über das Beispiel Addon
    `own-files-0.1` realisiert werden. Einfach das Kommentarzeichen vor
    `own-files-0.1` in addon/static.pkg entfernen und die gewünschten
    Dateien in das Verzeichnis `./addon/own-files-0.1/root/` an die
    Stelle kopieren, an der sie im root Dateisystem der Box landen
    sollen.
    Beispiel: eine Datei `./addon/own-files-0.1/root/usr/bin/foo` wird
    auf der Box in `/usr/bin/foo` landen.

> Dateien und Verzeichnisse, die unterhalb von `/var` liegen sollen
> können nach `./addon/own-files-0.1/var.tar` kopiert werden. Änderungen
> an diesen Dateien gehen bei jedem Reboot verloren.

### Erzeugen der Dateien aus der debug.cfg

Beim Booten werden die gewünschten Dateien im Verzeichnis `/tmp` neu
erstellt. Dazu wird das Script `debug.cfg` missbraucht, das beim Starten
der FritzBox automatisch ausgeführt wird. Da die `debug.cfg` selbst im
beschreibbaren TFFS des Flash (mtd3/4) liegt, gehen ihre Inhalte beim
Reboot nicht verloren.

Beispiel:

Der Code wird einfach in die `debug.cfg` eingefügt. Am einfachsten geht
es mit Putty:

-   Code in Zwischenablage kopieren
-   mit der Box via telnet / SSH verbinden
-   nvi /var/flash/debug.cfg
-   mit *: set paste RETURN* in den Einfügen/Paste Modus wechseln
-   an der passenden stelle "i" für insert drücken
-   rechte Maustaste auf Putty fügt den Text ein
-   nacheinander *ESC ESC : w q RETURN* drücken (Abbrechen wäre: *ESC
    ESC : q ! RETURN*)
-   Neustarten

Hier wird ein Skript erzeugt, das sich mit `/var/tmp/checkonline.sh`
aufrufen lässt. Es zeigt an, welcher der neun Rechner im FB-LAN online
ist. Wichtig ist, daß der "Endmarker" (hier 'ENDCHECK') **nicht
eingerückt** ist. Die letzte Zeile macht das Script ausführbar. Abbruch
mit STRG+C.

```
    cat > /var/tmp/checkonline.sh << 'ENDCHECK'
    #!/bin/sh

    while [ 1 = 1 ]
    do
         clear
         echo Online:
         date
         echo ------------------------------------------------
         for a in "2 Desktop1" "3 Michael" "20 Christina" "21 -" "22 -" "23 -" "24 -" "25 -" "26 -" "27 -" "28 -"  "29 -" "45 FB WLAN SL(WDS)"

         do
                  ping -c 1 192.168.178.$a |grep "bytes from ">/dev/null && echo 192.168.178.$a &
         done
         sleep 1
         echo ------------------------------------------------
         sleep 9
    done

    ENDCHECK
    chmod +x /var/tmp/checkonline.sh
```

### Nachladen vom Webserver

Beim Booten werden alle gewünschten Dateinen aus dem Internet oder von
einem Webserver im Intranet auf die Box geladen.

### Nachladen vom USB-Stick

Beim Booten werden alle gewünschten Dateinen direkt vom USB Stick bzw.
via FTP vom internen FTP Server auf die Box geladen.

### WebDAV Share mounten

Für Freetz gibt es das Paket
WebDAV, über das man einen
WebDAV-Share direkt mounten kann. Als Konsequenz werden alle
Remote-Dateien so behandelt, als wären sie lokal vorhanden, und zwar
ohne gesondertes Nachladen.

### NFS-Share mounten

Mit dem NFS Paket lässt sich
gleiches erreichen wie mit WebDAV (s.o.), nur etwas stabiler :)


