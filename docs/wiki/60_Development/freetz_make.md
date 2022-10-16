# Freetz Build-Prozeß

### Vorwort und Motivation

In den HowTos gibt es einige wichtige
Informationen darüber, was man mit *Make*-Targets wie
menuconfig, *toolchain*,
*precompiled*, *recover* usw. erreichen kann beim Bau einer
*Freetz*-Firmware. Trotzdem gibt es im Forum regelmäßig eine Menge
Fragen zum Build-Prozess - meistens, wenn der Prozess nicht durchläuft
und der betreffende Benutzer nicht weiß, woran das liegt. Der Grund ist
meistens, dass es sich um einen unerfahrenen Benutzer handelt, der mit
[GNU make](http://www.gnu.org/software/make/) keine
Erfahrung hat, weil er erstens nicht C/C++-Programmierer ist und/oder
zweitens bereits die Linux-Kommandozeile per se ein Buch mit sieben
Siegeln für ihn ist. Zumindest Ersteres trifft auf mich auch zu, und
deshalb habe ich mich mal oberflächlich eingelesen, um das `Makefile`
von *Freetz* besser (oder überhaupt) zu verstehen. Das Ergebnis meiner
Arbeit dokumentiere ich hier.

Die Probleme der Hilfesuchenden im Forum hören nämlich nicht damit auf,
dass der Build manchmal hängen bleibt. Da viele Fragen aus Sicht der
Cracks "dumm" klingen, sich häufig wiederholen - nicht jeder ist
geschickt darin, die Suchfunktion des Forums oder Google zu benutzen,
manche sind auch einfach zu faul - und somit manchen Profis lästig sind,
fallen die Antworten entsprechend kurz aus, was wiederum zu Rückfragen
und mehr "Müll" im Forum führt. Wenn dann der Hilfesuchende die
Ursache des Problems beseitigt hat (Linux-Package nachinstalliert,
richtige Option in `make menuconfig` an-/abgewählt, Patch installiert),
bekommt er oftmals den Build trotzdem nicht mehr ans Laufen, weil die
Abhängigkeiten nicht hunderprozentig sauber gepflegt sind und er
zunächst nochmal ein *xy-clean* und/oder *xy-precompiled* aufrufen
müsste, ihm das aber keiner gesagt hat, weil es auch schwer
vorherzusehen ist.

Der Traum vom perfekten `Makefile`, das bei jeder Dateiänderung genau
das tut, was minimal zu tun wäre, um das aktuelle Target zu bauen, ist
grundsätzlich erreichbar, bei uns aber nicht realisiert. Obwohl man
sagen muss, daß der Freetz *Make*-Prozess schon relativ gut ist - nur
eben nicht idiotensicher. Das war wohl auch nicht das Ziel, denn ein
"Idiot" sollte keine Firmware für seinen DSL-Router bauen wollen.
Andererseits ist es aber auch gut für unsere Gemeinschaft, wenn neuen
Mitgliedern die Lernkurve etwas angenehmer gestaltet wird. Es ergibt
keinen Sinn, dass jeder das Rad neu erfindet und sich alles selbst
erarbeitet, nur weil andere das früher hatten tun müssen.

### Grundsätzliches

Basis dieser Dokumentation ist **Freetz-1.1.4**. Da es inzwischen neuere
Freetz-Versionen gibt wird an einige Stellen auf Abweichungen
hingewiesen.

### Was tut make?

Das würde hier wirklich den Rahmen sprengen, daher nur ein paar Links.
Sich einzulesen, lohnt sich - Bildung ist nie umsonst:

-   [Wikipedia-Artikel zu
    Make](http://de.wikipedia.org/wiki/Make)
-   [Eine Einführung in
    Makefiles](http://www.ijon.de/comp/tutorials/makefile.html)
    (deutsch, kurz und knackig, leicht zu verstehen)
-   [Recursive Make Considered
    Harmful](http://members.tip.net.au/~millerp/rmch/recu-make-cons-harm.html)
    (hochspannend für Fortgeschrittene und Philosophen, PDF zum
    Herunterladen)
-   [Wikipedia-Artikel zu
    Autoconf](http://de.wikipedia.org/wiki/GNU_autotools)
    (nicht von *Freetz* selbst verwendet, aber von diversen Paketen)

### Woraus besteht Freetz?

Die modifizierte Firmware wird zusammengebaut aus mehreren Komponenten:

-   **Original-Firmware**, bestehend aus Linux-Kernel und -Dateisystem.
    Sie bildet die Basis und das Grundgerüst für den Mod.
    Fälschlicherweise wird von vielen Einsteigern angenommen, die
    Original-Firmware werde weggeworfen und komplett durch etwas
    Selbstgebautes ersetzt. Dem ist nicht so. Viele wichtige
    Bestandteile werden übernommen, wie sie sind und um neue Funktionen
    ergänzt bzw. Einzelteile gezielt ausgetauscht. Wichtige Bestandteile
    der Original-FW sind
    -   **Kernel** (früher 2.4, aktuell 2.6). Für Daniels Mod konnte ein
        2.4er Kernel übernommen werden, für Freetz muß er durch einen
        selbst gebauten 2.6er ersetzt werden. Nimmt man als Basis eine
        Original-FW mit 2.6er Kernel, kann man diesen übernehmen oder
        wahlweise ebenfalls ersetzen.
    -   **Dateisystem** mit Standard-UNIX-Tools und AVM-spezifischen
        Werkzeugen (z.B. Web-Oberfläche). Wird (fast) unverändert
        übernommen mit einer wichtigen Ausnahme (siehe nächster Punkt).
    -   **Busybox**: Sammlung der wichtigsten Kommandozeilenwerkzeuge,
        optimiert für Embedded-Systeme und enthalten in einer einzigen
        ausführbaren Datei. Die einzelnen Werkzeuge werden über
        symbolische Links auf die
        [Busybox](http://de.wikipedia.org/wiki/Busybox)
        als scheinbar eigenständige Namen realisiert.

**Freetz** selbst präsentiert sich nach dem Auspacken des entsprechenden
Archivs (z.B. `freetz-1.1.4.tar.bz2`) entsprechend der folgenden
alphabetisch, nicht nach Wichtigkeit, sortierten Liste. (Die
Unterverzeichnisse `build`, `packages`, `source` werden erst beim ersten
*Make*-Lauf erzeugt.)

-   **Root-Verzeichnis**: Hier befinden sich einige
    Konfigurationsdateien (später mehr dazu) sowie Change-Log, Firmwares
    und Read-Me. Desweiteren gibt es diverse Unterverzeichnisse:
    -   ***addon***: Hierhin werden statische und (theoretisch)
        dynamische Packages (bereits kompiliert) entpackt, die mit ins
        Dateisystem der Firmware sollen und über den "Lieferumfang"
        des Standard-Mods hinausgehen.
    -   ***build***: Nach *build/original* wird das
        Original-Firmware-Image entpackt. Die drei Einzelbestandteile
        liegen dann wiederum in den Unterverzeichnissen *kernel*
        (Linux-Kernel), *filesystem* (Root-Dateisystem) und *firmware*
        (im Firmware-Image auf oberster Ebene enthaltene, zu dessen
        Installation notwendige Werkzeuge). Diese Bestandteile werden,
        wie bereits erwähnt, verwebt mit den generierten Bestandteilen
        (Kernel, Busybox, Packages, Sonstiges) und in einer parallelen
        Verzeichnisstruktur *build/modified* gespeichert. Von dort
        wiederum werden sie geholt, um letztendlich das Firmware-Image
        mit *Tar* zusammenzupacken.
    -   ***busybox***: Ablageort der neu gebauten Busybox für den Mod
        (ab Freetz-1.2 unter
        packages/target-mips(el)_uClbic-\$(uClibc-Version)/busybox zu
        finden)
    -   ***dl***: Downloads von Quell-
        und Binärpaketen für Toolchain und Mod. Die Webinterfaces zu den
        Paketen sind bis auf wenige Ausnahmen direkt im Mod enthalten,
        andere Dateien werden während des Builds aus dem Internet
        mittels *wget* nachgeladen.
    -   ***favicon***: Hier liegen (momentan) zwei kleine Sätze von
        Favicons, die man über `make menuconfig` auswählen kann, um das
        Web-Interface von Freetz mit hübschen kleinen Icons im Browser
        zu versehen (werden angezeigt in der Adreßzeile und bei den
        Favoriten).
    -   ***howtos***: ein paar deutsche und englische Kurzanleitungen
        zum Bauen des Mods bzw. eigener Erweiterungen.
    -   ***kernel***: Ablageort des neu gebauten Linux-Kernels und
        dessen Modulen für den Mod
    -   ***make***: Pro Package liegen hier die Include-Files und
        Konfigurationsdaten für das "große" `Makefile` im
        Wurzelverzeichnis, sowie die Startskripte, cgi-Dateien und
        sonstige zum Paket gehörigen Files. Die Konfigurationsdaten
        enthalten auch die Versionsnummern der nach *dl*
        herunterzuladenden Pakete.
    -   ***packages***: Hierhin werden die gebauten Packages abgelegt.
        In einem Unterverzeichnis pro Paket (wie unter `make`) liegen
        dann die entsprechenden Binär- und Konfigurationsdaten, welche
        ins Dateisystem eingewebt werden - zu bewundern unter
        `build/modified`, vgl. voriger Punkt. (ab Freetz-1.2 kommt unter
        packages/ eine weitere Verzeichnis-Ebene hinzu; diese trennt
        nach big oder little endian und uClibc-Version)
    -   ***patches***: Patches, welche nach dem Entpacken in die Sourcen
        eingearbeitet werden, je nachdem, welche Hardware und/oder
        Konfigurationseinstellung man verwendet.
    -   ***root***: Abbild des (Root-)Dateisystems der späteren
        Firmware. Hier liegen Webseiten, Startskripte,
        Konfigurationsdaten usw.. Sie werden beim Bauen der Firmware mit
        den Originaldaten und weiteren erzeugten Dateien (z.B. Kernel,
        Busybox) zu einem kompletten Image verwoben.
        -   Freetz-1.2: Das Verzeichnis wurde nach make/mod/files/root
            verschoben, um eine Vereinheitlichung zu erreichen.
    -   ***source***: Hierhin werden sämtliche Quelltexte für Toolchain,
        AVM-GPL-Paket, Tools, Packages, Busybox und Kernel entpackt, um
        anschließend die entsprechenden Build-Prozesse darüber laufen
        lassen zu können.
        -   Freetz-1.2: Um eine bessere Trennung zu erreichen und
            unnötige *make dirclean*s zu vermeiden werden die Sourcen
            wie folgt aufgetrennt:
            -   ***host-tools***: Hierin werden die Tools (busybox,
                mksquashfs, fakeroot usw.) für den Host gebaut.
            -   ***kernel***: Kernelsourcen
            -   ***target-mips(el)_uClibc-\$(uClibc-Version)***: Hier
                werden die ausgewählten Pakete entpackt und gebaut.
            -   ***toolchain-mips(el)_gcc-\$(GCC-Version)_uClibc-\$(uClibc-Version)***:
                Toolchain Sourcen und Build. Enthält abhängig von der
                menuconfig-Auswahl binutils, ccache, gcc, gdb, uClibc,
                libtool.
    -   ***toolchain***: Nach dem Entpacken des Mods liegen hier die
        *Makefile*-Includes für das Bauen der Toolchains. Eine Toolchain
        i.a. ist eine Sammlung von Werkzeugen, welche notwendig sind, um
        Software zu bauen und enthalten z.B. Compiler und Linker. In
        unserem Fall gibt es zwei separate Toolchains für das Bauen des
        Kernels zum einen (`gcc-3.4.6`) und der übrigen Targets zum
        anderen (`gcc-4.2.1-uClibc-0.9.28/0.9.29`). In entsprechende
        Unterverzeichnisse werden die Toolchains dann auch übersetzt.
        Das Bauen der Toolchains ist optional, da es vorkompilierte
        Versionen zum Download gibt.
        Abhängig von der Geschwindigkeit des Hosts kann der Toolchain
        Bau zwischen 20 - 60 Minuten dauern.
        -   Freetz-1.2: Die GCC-Versionen wurden auf einen aktuellen
            Stand gebracht (gcc-4.4.6, gcc-4.5.3 und gcc-4.6.0).
    -   ***tools***: Hier liegen weitere Werkzeuge bzw. deren
        `Makefile`-Includes, welche zum Bauen der Firmware-Images bzw.
        für `make recover` notwendig sind. Mit den Werkzeugen werden
        z.B. die Original-Firmwares entpackt (SquashFS-Dateisystem) und
        die späteren Mod-Images nach dem Einweben aller Bestandteile
        wieder zusammen geschnürt. Eine ältere tar-Version (15.1), die
        mit den in den Original-Firmwares enthaltenen Entpackern
        kompatible Firmware-Archive erzeugt, gehört neben anderen
        Helferlein ebenfalls dazu.
        -   Freetz-1.2: Das tar-Paket wird nicht mehr als Tool gebaut.
            Es wird abhängig von der Aufgabe das Host-tar oder
            busybox-tar verwendet.

### Ablauf des Build-Prozesses

Es dürfte allgemein bekannt sein, daß die drei wichtigsten Make-Targets
- in dieser Reihenfolge aufzurufen - lauten:

-   `make menuconfig` - interaktiv Pakete zusammenstellen, zusätzliche
    Bibliotheken auswählen, Konfiguration speichern
-   `make` - Tools bauen, Toolchains bauen (sofern kein externer
    Compiler ausgewählt wurde), danach Bibliotheken, Linux-Kernel und
    Packages bauen, abschließen Firmware bauen.

Daneben gibt es eine beträchtliche Anzahl weiterer
Make-Targets,
die teilweise nicht direkt im Makefile sichtbar sind, sondern durch
automatisierte Ersetzungsvorgänge erzeugt werden. Das hat den Vorteil,
daß es z.B. pro Package jeweils die gleichen Sub-Targets gibt und man
somit immer die Möglichkeit hat, durch einen *Make*-Aufruf direkt
Einfluß auf einzelne Pakete zu nehmen (z.B. aufräumen, nochmal neu
übersetzen). Wenn also `make precompiled` beispielsweise im Paket
mc hängen geblieben ist, weil ein
zum Bauen notwendiges Linux-Paket in unserer Distribution gefehlt hat,
das wir erst noch per Paketmanager installieren mussten, kann es sein,
dass ein erneuter Aufruf des globalen *precompiled* anschließend
trotzdem nicht durchläuft, weil es Inkonsistenzen im Package-Build gibt.
Da hilft dann meistens eine Sequenz wie `make <Paket>-clean`,
`make <Paket>-precompiled`, also z.B. *mc-clean* und *mc-precompiled*.
Wie die Pakete heißen, sieht man an den Namen der Unterverzeichnisse im
Verzeichnis `make`.

### Include-Kette

Es gibt generell zwei Arten, *Make* für hierarchisch strukturierte
Builds zu benutzen. Die eine, althergebrachte, geht von einem `Makefile`
im Hauptverzeichnis und jeweils einem weiteren `Makefile` pro
Unterverzeichnis aus. Daß dies keine gute Idee ist, wird in
[Recursive Make Considered
Harmful](http://members.tip.net.au/~millerp/rmch/recu-make-cons-harm.html)
überzeugend dargelegt. Die gute Nachricht ist: Freetz verwendet die
zweite Methode, und zwar Include-Dateien in den Unterverzeichnissen.
D.h., das `Makefile` lädt die für das aktuelle Target notwendigen
Includes dynamisch nach und erzeugt so ein einziges, großes, virtuelles
`Makefile`, welches dann abgearbeitet wird. Das ist schön, führt aber
dazu, daß wir im `Makefile` sehen, wie Dinge aufgerufen und abgearbeitet
werden, deren Herkunft nicht ganz so leicht festzustellen ist, wenn man
sich nicht im Detail die Verzeichnisstruktur ansieht. Ich versuche hier,
das ein wenig transparenter zu machen.

-   Zunächst inkludiert das `Makefile` die Konfigurationsdatei `.config`
    im Hauptverzeichnis. Sie wiederum enthält die in `make menuconfig`
    festgelegten Optionen für die Zusammenstellung des Firmware-Images.
    Damit wird schon klar, weshalb wir `make menuconfig` immer als
    erstes aufrufen sollten. Die Datei existiert übrigens direkt nach
    dem Auspacken des Mod-Archivs auch noch gar nicht. Ausnahme für den
    Include: Sofern wir nur Targets aus der Gruppe *menuconfig, config,
    oldconfig, defconfig, tools* bauen wollen, erfolgt kein Include an
    dieser Stelle, da diese Targets ihn nicht benötigen.
-   Etwas später erfolgt das Inkludieren von `tools/make/Makefile.in`
    sowie `tools/make/*.mk`, was dazu führt, daß die einzelnen
    Tool-Targets (*find-squashfs, lzma, squashfs, tichksum, makedevs,
    fakeroot*) der Variablen *TOOLS* hinzugefügt werden. Anschließend
    wird pro Tool-Target noch eine Liste von Sub-Targets erzeugt:
    -   ***\<tool\>***: Baut das Tool.
    -   ***\<tool\>-source***: Packt die Quelldateien aus, damit
        anschließend das Tool gebaut werden kann.
    -   ***\<tool\>-clean***: Ruft im Tool-Unterverzeichnis das eigene
        `Makefile` des Tools mit `make clean` auf. Das Target *clean*
        löscht meistens sämtliche generierten Dateien und Verzeichnisse,
        um anschließend sauber neu aufsetzen zu können.
    -   ***\<tool\>-dirclean***: Löscht das gesamte
        Tool-Unterverzeichnis. Das ist praktisch, wenn man eine neuere
        Version auspacken und die alte vorher komplett wegräumen möchte.
    -   ***\<tool\>-distclean***: Löscht im Tool-Unterverzeichnis das
        Distributions-Verzeichnis, in dem die gebauten Dateien
        installationsfertig liegen.
-   Jetzt ist `.config.cmd` dran. Dadurch werden rekursiv
    Konfigurations-Schalter diverser Pakete eingelesen, die später dem
    Build zur Verfügung stehen.
-   Richtig rund geht es jetzt, denn include `make/pkgs/Makefile.in`,
    `make/pkgs/*/Makefile.in`, `make/toolchain/Makefile.in` und die
    entsprechenden ***\*.mk***-Dateien sorgen für noch mehr
    Informationen im virtuellen `Makefile`. Anschließend haben wir,
    analog zu den Tools oben, folgende Targets zur Verfügung, die sich
    in die Gruppen *TARGETS, PACKAGES, LIBS, TOOLCHAIN* aufteilen:
    -   ***\<target\>-precompiled***: Baut ein Target, das nicht zu
        einem Package, zur Gruppe der Bibliothekten-Targets oder zur
        Toolchain gehört. Darunter fallen z.B. der Linux-Kernel, der
        CGI-Mod (Web-Oberfläche von Freetz), die Busybox, das CGI-Tool
        Haserl (momentan kein Package), iptables sowie die
        AVM-GPL-Quellen.
        -   Freetz-1.2: Zu den Targets zählen nur noch der Kernel sowie
            die Busybox.
    -   ***\<target\>-source***: Packt die Quelldateien aus, damit
        anschließend das Target gebaut werden kann.
    -   ***\<target\>-clean***: Ruft im Target-Unterverzeichnis das
        eigene `Makefile` des Targets mit `make clean` auf. Das Target
        *clean* löscht meistens sämtliche generierten Dateien und
        Verzeichnisse, um anschließend sauber neu aufsetzen zu können.
    -   ***\<target\>-dirclean***: Löscht das gesamte
        Target-Unterverzeichnis. Das ist praktisch, wenn man eine neuere
        Version auspacken und die alte vorher komplett wegräumen möchte.
    -   ***\<package\>-precompiled***: Baut ein Package.
    -   ***\<package\>-source***: Packt die Quelldateien aus, damit
        anschließend das Package gebaut werden kann.
    -   ***\<package\>-clean***: Ruft im Package-Unterverzeichnis das
        eigene `Makefile` des Packages mit `make clean` auf. Das Target
        *clean* löscht meistens sämtliche generierten Dateien und
        Verzeichnisse, um anschließend sauber neu aufsetzen zu können.
    -   ***\<package\>-dirclean***: Löscht das gesamte
        Package-Unterverzeichnis. Das ist praktisch, wenn man eine
        neuere Version auspacken und die alte vorher komplett wegräumen
        möchte.
    -   ***\<package\>-list***: Fügt das Package entweder der Liste der
        statischen oder der dynamischen Pakete hinzu.
    -   ***\<lib\>-precompiled***: Baut eine Bibliothek, z.B. ncurses,
        libgcrypt, openSSL.
    -   ***\<lib\>-source***: Packt die Quelldateien aus, damit
        anschließend die Bibliothek gebaut werden kann.
    -   ***\<lib\>-clean***: Ruft im Bibliotheks-Unterverzeichnis das
        eigene `Makefile` der Bibliothek mit `make clean` auf. Das
        Target *clean* löscht meistens sämtliche generierten Dateien und
        Verzeichnisse, um anschließend sauber neu aufsetzen zu können.
    -   ***\<lib\>-dirclean***: Löscht das gesamte
        Bibliotheks-Unterverzeichnis. Das ist praktisch, wenn man eine
        neuere Version auspacken und die alte vorher komplett wegräumen
        möchte.
    -   ***\<toolchain\>***: Baut die Toolchains (Kernel- und
        Target-Toolchain).
    -   ***\<toolchain\>-source***: Packt die Quelldateien aus, damit
        anschließend die Toolchain gebaut werden kann.
    -   ***\<toolchain\>-clean***: Ruft im Toolchain-Unterverzeichnis
        das eigene `Makefile` der Toolchain mit `make clean` auf. Das
        Target *clean* löscht meistens sämtliche generierten Dateien und
        Verzeichnisse, um anschließend sauber neu aufsetzen zu können.
    -   ***\<toolchain\>-dirclean***: Löscht das gesamte
        Toolchain-Unterverzeichnis. Das ist praktisch, wenn man eine
        neuere Version auspacken und die alte vorher komplett wegräumen
        möchte.
    -   ***\<toolchain\>-distclean***: Löscht im
        Toolchain-Unterverzeichnis das Distributions-Verzeichnis.
-   Im vorigen Schritt kamen noch zwei weitere Targets hinzu, die es
    ermöglichen, zwei zentrale Teile der Firmware noch individueller zu
    gestalten:
    -   ***kernel-menuconfig***: Auch der Linux-Kernel hat eine hübsche
        Konfigurationsoberfläche, in der man allerhand einstellen kann.
        Ich halte es persönlich für wenig empfehlenswert, hier etwas zu
        ändern - es sei denn, man kennt sich wirklich gut damit aus. Es
        wird sehr schwierig, im Forum Hilfe zu finden, wenn man einen
        anders konfigurierten Kernel hat als der Rest der Welt.
    -   ***busybox-menuconfig***: Auch die Busybox kann man an diversen
        Stellen um Features ergänzen auf Kosten ihrer Größe. Die
        Besitzer der 8-MB-Boxen (z.B. 7170) haben in der Regel noch
        genug Platz, um hier das eine oder andere Feature hinzuzufügen.
        Hier empfehle ich, nichts wegzulassen, was standardmäßig
        enthalten ist, damit auch wieder die Vergleichbarkeit bei
        Diskussionen im Forum da ist. Es bringt nichts, das
        *Gunzip*-Feature in *Tar* zu deaktivieren und hinterher dann im
        Forum zu fragen, weshalb ein *Gzip*-Archiv nicht entpackt werden
        konnte. Hingegen stört es wenig, wenn man zusätzlich *Bunzip2*
        aktiviert, weil es ja nur ein Zusatz ohne Seiteneffekte (nach
        menschlichem Ermessen) ist.

### Sonstige Make-Targets

Direkt im Top-Level-`Makefile`, also nicht inkludiert, sind weitere
Targets enthalten.

-   Teilweise handelt es sich um **Hilfs-Targets**, welche man selten
    manuell aufrufen wird, weil sie hauptsächlich zur Verwendung seitens
    übergeordneter Targets gedacht sind. Beispiele hierfür sind *config,
    oldconfig, defconfig*.
-   Desweiteren gibt es das Utility-Target ***recover***, mit welchem
    man eine zerschossene Box wiederbeleben kann (Details würden den
    Rahmen des Artikels sprengen).
-   Dann gibt es noch **Sammel-Targets** wie *sources, precompiled,
    libs, packages-precompiled*, welche eine ganze Gruppe ähnlich
    lautender oder dem Zweck nach verwandter Sub-Targets aufrufen.
-   Wenn man nur eine Firmware zusammenbauen möchte und alle dafür
    notwendigen Vorarbeiten (Toolchains bauen, `make precompiled`)
    bereits erledigt sind, kann man das Target ***firmware*** benutzen.
    Es baut bei Bedarf noch die Tools (nicht mit den Toolchains zu
    verwechseln) und macht sich dann ans Werk. Am Ende hat man ein
    Firmware-Image im images-Verzeichnis mit dem Namen *\*.image*. Das
    Target wird implizit aufgerufen, wenn mann einfach `make` aufruft,
    also das Default-Target baut. Übrigens erledigt das Skript `fwmod`
    im Wurzelverzeichnis die ganze Arbeit des Firmware-Bauens. Es ist
    sicher interessant, sich dieses Skript mal im Detail anzusehen, wenn
    man wissen möchte, was da so alles passiert.

So, ich hoffe, dieser Artikel bringt dem einen oder anderen Modder
etwas. Diskussionen, Feedback, Korrekturen hierzu sind wie immer
willkommen und können im zugehörigen
[Forums-Thread](http://www.ip-phone-forum.de/showthread.php?t=129115)
eingebracht werden.

[Alexander Kriegisch
(kriegaex)](http://www.ip-phone-forum.de/member.php?u=117253)\
Überarbeitet von Oliver Metz


