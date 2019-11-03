# Add FREETZMOUNT
Vergibt einheitliche Namen für USB-Speichermedien, verbessert deutlich die Unterstützung der USB-Speichermedien, ermöglicht mounten nach LABEL.
FREETZMOUNT ist der Nachfolger vom USB-Storage-Patch und beinhaltet auch autorun/autoend patch.
Nach dem Umstieg zu FREETZMOUNT wird es empfohlen das Paket fstyp manuell abzuwählen.<br>
<br>

FREETZMOUNT ist der Nachfolger-Patch vom ehemaligen USB-Storage-Patch. Neben den Funktionen vom USB-Storage-Patch beinhaltet er auch die autorun/autoend-Funktionalität (konfigurierbar via Webinterface).
FREETZMOUNT greift tiefer als die beiden Vorgänger-Patches in die AVM-Mount-Struktur ein und lagert Teile der Mountskripte von /etc/hotplug/storage und /etc/hotplug/run_mount in die FREETZ-eigene Bibliothek /usr/lib/libmodmount.sh aus. Dadurch wird der Wartungsaufwand für diese Patches reduziert, das Mount-Verhalten wird für alle Box-/Firmware-Versionen vereinheitlicht.
FREETZMOUNT ermöglicht das Mounten der Medien nach einem sogenannten LABEL, einer einheitlicher Bezeichnung für die Medien. Dadurch wird gewährleistet, dass das Medium (Partition) immer unter dem selben Mount-Punkt zu finden sein wird (Bekämpfen vom uStor11-Problem).

Anmerkungen:

 * Bei der Auswahl des "mount-by-label"-Features wird fstyp nicht mehr benötigt und kann abgewählt werden: Package-Selection → Testing → fstyp.
 * Obwohl es eigentlich offensichtlich sein sollte, hier noch einmal zur Verdeutlichung:

Ein Programm, welches für's Mounten in irgendeiner Art und Weise zuständig ist, darf nicht auf einem zu mountenden Medium externalisiert sein.
Dazu gehören zum Beispiel e2fsck,ntfs-3g und blkid.

Weiterführende Infos gibt es z.B. in folgenden Threads des IP-Phone-Forums:

 * [FREETZMOUNT: Mounten ohne 1000 und ein Mal zu patchen](http://www.ip-phone-forum.de/showthread.php?t=200293)
 * [​/etc/hotplug/run_mount modifizieren](http://www.ip-phone-forum.de/showthread.php?t=200293)
 * [​Skript für immer gleiche Mountpoints (auch nach Verlust des Mounts)](http://www.ip-phone-forum.de/showthread.php?t=181859)

