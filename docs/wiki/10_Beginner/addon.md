# Addon Paket installieren

Pakete, die noch nicht in Freetz integriert sind, können als sogenanntes
*Addon Paket* installiert werden. Dazu das gewünschte Paket **vor** dem
Erstellen des Image herunterladen und nach `./addon` entpacken.
Folgendes Beispiel geht davon aus, dass man sich im Verzeichnis des
entpackten Freetz befindet:

```
tar -C addon -xjvf /pfad/zu/addon-paket-0.1-freetz.tar.bz2
```

Danach muss das Paket in der Liste `./addon/static.pkg` in eine neue
Zeile eingetragen werden (im obigen Beispiel: `addon-paket-0.1`). Addon
Pakete werden nach den integrierten Paketen in der Reihenfolge des
Auftretens in `./addon/static.pkg` gestartet.

Hinweis: Falls es sich bei dem Addon Paket um eine andere Version eines
bereits integrierten Pakets handelt, so sollte das ursprüngliche Paket
in `make menuconfig` unter *Package selection* deaktiviert werden, um
Versionskonflikte zu vermeiden.


### Erweiterung ab r15856 / 3dda64565e

Es können ```addon/*.pkg``` zum aktivieren verwendet werden. Dies hat den
Vorteil dass man die ```.pkg``` mit ins Addon-Archiv packen kann, und dadurch
keine anderen Addons deaktiviert werden.<br>
Auch kann man so leichter Updates verteilen, wenn die Versionsnummer nicht
in Dateinamen der ```.pkg``` steht

Beispiel mit zwei Addons:
- Verzeichnis ```addon/ding-v1/```, Datei ```addon/ding.pkg``` mit ```ding-v1``` darin
- Verzeichnis ```addon/dong-v1/```, Datei ```addon/dong.pkg``` mit ```dong-v1``` darin

Update von einem Addon:
- Verzeichnis ```addon/ding-v2/```, Datei ```addon/ding.pkg``` mit ```ding-v2``` darin

Es wird so automatisch die alte Version des Addons deaktiviert und die neue aktiviert.

