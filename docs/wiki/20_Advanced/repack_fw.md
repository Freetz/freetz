# Entpacken und Packen von Firmware-Images

Wenn man ein Firmware-Image entpacken, ändern und wieder packen möchte,
geht das wie folgt (nach Anleitung von [Alexander
Kriegisch](http://www.ip-phone-forum.de/member.php?u=117253)
- in [diesem
Forums-Thread](http://www.ip-phone-forum.de/showthread.php?t=175974):

### Tools und Syntax

Am einfachsten ist es, Freetz als Infrastruktur zu benutzen, und zwar
das Skript `fwmod` aus dem Freetz-Hauptverzeichnis. Wenn man es ohne
Parameter aufruft, verrät es wie es benutzt werden möchte:

```
	$ ./fwmod

	Usage: fwmod [-u|-m|-p|-a] [-i <cfg>] [-d <dir>] <orig_fw> [<tk_fw> [<aux_fw>]]
	  actions
		-u         unpack firmware image
		-m         modify previously unpacked image
		-p         pack firmware image
		-a         all: unpack, modify and pack firmware image (-u -m -p, default)
	  special actions
		-n         firmware-nocompile: do not install kernel and busybox
		-f         force pack even if image is too big for flash (AVM SDK)
		-z         zip file system into archive for USB/NFS root
		-c <dir>   copy file system to target directory for NFS/USB root (implies -z)
	  input/output
		-i <cfg>   input file for configuration data (default: .config)
		-d <dir>   build directory (default: <orig_firmware>.mod)
		<orig_fw>  original firmware name
		<tk_fw>    2nd firmware name (e.g. for merging in web UI)
		<aux_fw>   3rd firmware name (e.g. to borrow missing files)
```

Man braucht also einmal den Aufruf mit `-u` zum Entpacken, dann nach der
Modifikation den mit `-p` zum erneuten Packen.

### Vorgehensweise

Im Folgenden wird davon ausgegangen, dass sich der Benutzer im
Hauptverzeichnis des frisch ausgepackten oder ausgecheckten Freetz
befindet und das zu modifizierende Firmware-Image bereits in dieses
Verzeichnis heruntergeladen hat. Dann sind folgende Schritte
auszuführen:

1.  Zunächst muss man eine passende Konfigurationsdatei *.config*
    erzeugen, damit beim Packen später das Skript *fwmod* die
    erforderlichen Informationen findet. Dazu ruft man einmal *make
    menuconfig* auf, wählt die richtige Hardware (z.B. 7170) aus und
    verlässt die Konfiguration, wobei man die Frage nach dem Abspeichern
    bejaht.
2.  Bevor man *fwmod* erstmals aufrufen kann, müssen einige Werkzeuge
    gebaut werden, die später indirekt aufgerufen werden, um die
    Firmware zu entpacken und später wieder zusammenzubauen: *make
    tools*. Das kann ein Weilchen (einige Minuten) dauern.
    Internet-Downloads via *wget* müssen dazu funktionieren.
3.  Jetzt entpackt man das von AVM heruntergeladene Firmware-Image in
    ein Verzeichnis, das hier beispielhaft *unpacked_firmware* genannt
    wird:

    ```
		./fwmod -u -d unpacked_firmware FRITZ.Box_Fon_WLAN_7170.29.04.59.image
    ```

4.  Unter *unpacked_firmware/original/filesystem* modifiziert man dann
    das Dateisystem der Firmware.
5.  Zum guten Schluss packt man dann wieder das Firmware-Image:\

    ```
		./fwmod -p -d unpacked_firmware FRITZ.Box_Fon_WLAN_7170.29.04.59.image
    ```

Das ist also der gleiche Aufruf wie vorher, nur mit `-p` statt `-u`. Den
Namen des Original-Images muss man leider mit angeben, obwohl das Image
zum Packen nicht benötigt wird. Das ist eine kleine Schwäche des Skripts
`fwmod`.

6.  Nach einer Weile steht am Ende der Skript-Ausgabe so etwas wie

    ```
		creating filesystem image
		merging kernel image
		 kernel image size: 6969088 (max: 7798784, free: 829696)
		packing 7170_.de_20080923-200251.image
		done.

		FINISHED
    ```

**Anmerkungen zu den Freetz-Versionen bis einschließlich 1.1:**

-   Bei diesen Versionen muss den beiden `fwmod`-Aufrufen folgender
    fakeroot-Teil vorangestellt werden `tools/build/bin/fakeroot -- `
    (fwmod hat es erwartet in fakeroot-Umgebung aufgerufen zu werden und
    hat sich selbst um diese noch nicht gekümmert)
-   Bei Fehlermeldung
    `` fakeroot: preload library `libfakeroot.so' not found, aborting. ``
    hilft ein vorangestelltes LD_PATH_PRELOAD:

    ```
		LD_PATH_PRELOAD=tools/build/lib/libfakeroot.so tools/build/bin/fakeroot -- ./fwmod ...
    ```

### Verwendung von fwmod im "no freetz"-Modus

Seit trunk Changeset r13796
ist es möglich fwmod im quasi "no freetz"-Modus zu verwenden. Vom
Ablauf her entspricht dieser Modus dem Bauen einer freetz-modifizierten
Firmware. In diesem Modus wird jedoch keine einzige freetz-Änderung
vorgenommen. Stattdessen wird ein Hook aufgerufen, in dem man eigene
Modifikationen der Firmware implementieren und automatisiert ausführen
lassen kann. Konkret gehe man wie folgt vor:

1.  Man rufe `make menuconfig` auf, schalte den Experten-Modus ein
    ("Level of User Competence" = Expert), wähle die richtige Hardware
    (z.B. 7390) aus und aktiviere anschließend unter "Firmware
    packaging (fwmod) options" die Option "Skip modifying unpacked
    firmware, adding Freetz stuff". Der letzte Schritt entspricht dem
    Aktivieren des "no freetz"-Modus. Seit Fritz!OS-6.5x empfiehlt es
    sich weiterhin die Option "Sign image" (ebenfalls unter "Firmware
    packaging (fwmod) options" zu finden) zu aktivieren (s. dazu den
    [Signieren von
    Firmware](http://trac.freetz.org/wiki/help/howtos/development/sign_image)-Artikel).
2.  Die eigenen Mods der Firmware sind in dem Script
    [fwmod_custom](http://trac.freetz.org/browser/trunk/fwmod_custom)
    in der Funktion
    [all_no_freetz](http://trac.freetz.org/browser/trunk/fwmod_custom?rev=13796#L14)
    zu implementieren. Das entpackte Root-Dateisystem steht dabei unter
    `./filesystem` zur Verfügung. fwmod_custom enthält bereits einige
    auskommentierte Beispiele: [restore telnet
    support](http://trac.freetz.org/browser/trunk/fwmod_custom?rev=13796#L17),
    [restore debug.cfg
    support](http://trac.freetz.org/browser/trunk/fwmod_custom?rev=13796#L25).
3.  Anschließend rufe man `make` auf. Das entpackte,
    fwmod_custom-modifizierte, wieder zusammengepackte und ggf.
    signierte Image ist unter `images/` zu finden.

    ```
		STEP 1: UNPACK
		unpacking firmware image
		removing NMI vector from SquashFS
		NMI vector v1 found at offset 0xBE0000, removing it ... done.
		splitting kernel image
		unpacking filesystem image
			Reading a different endian SQUASHFS filesystem on build/original/kernel/kernelsquashfs.raw
			Filesystem on build/original/kernel/kernelsquashfs.raw is lzma compressed (3:76)
			Parallel unsquashfs: Using 1 processor
			6112 inodes (6522 blocks) to write
			created 5328 files
			created 373 directories
			created 697 symlinks
			created 87 devices
			created 0 fifos
		unpacking AVM plugins
			tam image
			webcm_interpreter image
			wlan image
		unpacking var.tar
		done.

		detected firmware 7390_de 84.06.80 rev43122 (07.02.2017 12:23:41)

		STEP 3: PACK/SIGN
		WARNING: Modifications (STEP 2) and this step should never
				 ever be run with different configurations!
				 This can result in invalid images!!!
		WARNING: firmware does not seem to be modified by the script
		invoking custom script
		  restoring support for /var/flash/debug.cfg
			patching ./filesystem/etc/init.d/rc.tail.sh
		  checking for left over Subversion directories
		packing var.tar
		Image signing files found, checking their consistency
		Copying /home/gene/.freetz.image_signing.asc to /etc/avm_firmware_public_key9
		creating filesystem image
		  SquashFS block size: 64 kB (65536 bytes)
		merging kernel image
		  kernel image size: 14.6 MB, max 14.9 MB, free 0.3 MB (269568 bytes)
		  WARNING: Not enough free flash space for answering machine!
		adding checksum to kernel.image
		packing images/7390_06.80.de_20170220-222457.image
		  image file size: 16.8 MB
		signing images/7390_06.80.de_20170220-222457.image
		  signed image file size: 16.8 MB
		done.

		FINISHED
    ```


