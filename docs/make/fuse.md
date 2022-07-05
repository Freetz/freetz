# FUSE 2.9.7 (binary only)
 - Package: [master/make/fuse/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/fuse/)

**[FUSE](http://de.wikipedia.org/wiki/Filesystem_in_Userspace)**
([Filesystem](http://de.wikipedia.org/wiki/Dateisystem)
in
[Userspace](http://de.wikipedia.org/wiki/Userspace))
ist ein
[Kernel-Modul](http://de.wikipedia.org/wiki/Kernel-Modul),
das es ermöglicht, Dateisystem-Treiber aus dem
[Kernel-Mode](http://de.wikipedia.org/wiki/Betriebssystemkern)
in den
[User-Mode](http://de.wikipedia.org/wiki/Ring_(CPU))
zu verlagern. Auf diese Weise können auch nicht-priviligierte Benutzer
(also jene, die nicht *root* heißen) Dateisysteme einbinden bzw.
erstellen. Die *FUSE* Module agieren quasi als "Bridge" zu den
Kernel-Schnittstellen.

*FUSE* lässt sich besonders gut einsetzen, um virtuelle Dateisysteme zu
verwirklichen. Anders als bei traditionellen Dateisystemen, die sich um
das Speichern und Laden von Daten auf der Disk zu kümmern haben,
speichern virtuelle Dateisysteme selbst keine Daten. Sie sind vielmehr
eine "View" oder "Übersetzung" eines bereits existierenden Datei-
oder Speichersystems. Im Prinzip kann jede für *FUSE* verfügbare
Resource als Dateisystem exportiert werden.

In Freetz basiert z.B. das [NTFS](ntfs-3g.html) Paket auf *FUSE*.

### Weiterführende Links

-   [Wikipedia:
    FUSE](http://de.wikipedia.org/wiki/Filesystem_in_Userspace)
-   [FUSE Project
    Homepage](http://fuse.sourceforge.net/) (Sourceforge)
-   [Official list of FUSE
    filesystems](http://fuse.sourceforge.net/wiki/index.php/FileSystems)
-   [Develop your own filesystem with
    FUSE](http://www.ibm.com/developerworks/linux/library/l-fuse/)
-   s3fslite für Freetz:
    Ticket #796
