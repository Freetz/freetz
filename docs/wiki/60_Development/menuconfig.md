# Menükonfiguration pflegen

Einer der ersten Schritte jedes ***Freetz***-Benutzers ist die Auswahl
der gewünschten Firmware (FW)-Konfiguration mit `make menuconfig`. Die
Menükonfiguration (MK) ist mithin die primäre Benutzerschnittstelle
neben der Linux-Shell für alle Nicht-Entwickler. Fehler und
Unstimmigkeiten, welche dort auftauchen, können bestenfalls zu
Verwirrung und Fragen im [IPPF
Freetz-Forum](http://www.ip-phone-forum.de/forumdisplay.php?f=525)
führen, aber auch zu seltsamen Warnungen auf der Konsole nach dem
Speichern der Konfiguration, zu fehlenden oder überflüssigen
FW-Bestandteilen oder schlimmstenfalls zu Freetz-Boxen, die nicht mehr
booten oder in Reboot-Schleifen festhängen. In jedem Fall entsteht
Support-Aufwand. Am billigsten sind, gemäß dem agilen Mantra "fail
early", jedoch Fehler, die frühestmöglich bemerkt werden oder am besten
gar nicht erst entstehen. Die Pflege der Menükonfiguration ist ein
wichtiger Qualitäts-Baustein unseres Projektes.

### Einstieg

Pflichtlektüre jedes Entwicklers, bevor er zum ersten Mal die MK anpaßt,
sollte die tools/kconfig/kconfig-language.txt
sein. Dort werden Syntax-Features und deren Gebrauch grundlegend
erklärt. Die Beschreibung entstammt der Dokumentation des
[Linux-Kernels](http://kernel.org), welchem wir
(und auch andere quelloffene Projekte) diese Art der MK und die dazu
notwendigen Werkzeuge entlehnt haben.

Die wichtigste Dateien und *Make*-Targets, mit welchen wir es im
Folgenden zu tun haben werden, sind

-   Config.in
    -   enthält das Hauptgerüst der MK
    -   ist in der *Kconfig*-Sprache geschrieben
    -   inkludiert hierarchisch (Baumstruktur) mittels
        `source`-Direktive weitere MK-Definitionen, welche ebenfalls
        Namen wie *Config.in, externals.in* o.ä. tragen
    -   wird zukünftig (Trunk-Merge steht kurz bevor) als Ganzes, also
        mit allen Includes, gepuffert in *Config.in.cache*, um
        Ladezeiten beim Aufruf von `make menuconfig` zu verringern.
-   *.config*
    -   enthält die vom Benutzer erstellte FW-Konfiguration als
        maßgebliche Vorausstzung für folgende Builds
    -   ist als Kopie in der FW unter */etc/.config* enthalten, sofern
        das nicht in der MK vor dem Build deselektiert wird
    -   ist eines der primären Debugging-Werkzeuge, wenn Benutzer Fehler
        mit einer bestimmten Konfiguration melden
    -   kann, sollte aber nicht manuell editiert werden
-   *tools/kconfig/mconf*
    -   ist das Binary, welches von `make menuconfig` aufgerufen wird,
        um die MK anzuzeigen und zu speichern
    -   wird mittels `make tools` bzw. `make kconfig-host` automatisch
        gebaut, sobald es benötigt wird
    -   hat auch ein *Make*-Target `menuconfig-single`, welches die KM
        als Baumstruktur ohne Unterseiten darstellt (manchmal nett, wenn
        man die Gesamtstruktur sehen bzw. bearbeiten möchte)
-   *tools/kconfig/conf*
    -   ist die Kommandozeilenversion von *mconf*
    -   hat mehr Features
    -   wird ebenfalls mittels `make tools` bzw. `make kconfig-host`
        automatisch gebaut, sobald es benötigt wird
    -   wird von den *Make*-Targets `config`, `oldconfig`,
        `oldnoconfig`, `defconfig`, `allnoconfig`, `allyesconfig`,
        ` randconfig`, `listnewconfig`, `config-clean-deps` und
        `config-clean-deps-keep-busybox` benutzt
    -   zeigt folgende Hilfe an, wenn ohne Parameter aufgerufen (klappt
        Stand 15.10.2011 im Trunk, nicht in älteren Stable-Versionen,
        also frühestens ab *Freetz 1.2*):

        ```
			Usage: tools/kconfig/conf [option] <kconfig-file>
			[option] is _one_ of the following:
			  --listnewconfig         List new options
			  --oldaskconfig          Start a new configuration using a line-oriented program
			  --oldconfig             Update a configuration using a provided .config as base
			  --silentoldconfig       Same as oldconfig, but quietly, additionally update deps
			  --oldnoconfig           Same as silentoldconfig but set new symbols to no
			  --defconfig <file>      New config with default defined in <file>
			  --savedefconfig <file>  Save the minimal current configuration to <file>
			  --allnoconfig           New config where all options are answered with no
			  --allyesconfig          New config where all options are answered with yes
			  --allmodconfig          New config where all options are answered with mod
			  --alldefconfig          New config with all symbols set to default
          --randconfig            New config with random answer to all options
        ```

Siehe vorerst
Ticket #1532 "enhancement: Warnings im Zusammenhang mit neuem Kconfig (menuconfig) (closed: fixed)"
, insbes. Kommentare Nr.

-   **Ticket #1532 "Kommentar 10 für Ticket #1532":
    Erklärung einer Warnung mit Vorschlägen zur Problembehebung**

    > Diese *unmet dependencies* behebt am besten jeder so, wie der
    > gerade drauf stößt. Es sind ja nur Warnings, aber die sind auch
    > wichtig, damit wir Unsauberkeiten aus den *Config.in* heraus
    > bekommen. Das ist also gut für die Projekthygiene. Ich gebe mal
    > ein Beispiel:
    >
	> ```
	>	 warning: (FREETZ_PACKAGE_AUTOFS_NFS && FREETZ_PACKAGE_NFSROOT)
	>	     selects FREETZ_MODULE_nfs which has unmet direct dependencies
	>	     (FREETZ_KERNEL_VERSION_2_6_13_1 || FREETZ_KERNEL_VERSION_2_6_28 ||
	>	      FREETZ_KERNEL_VERSION_2_6_32)
    > ```
    >
    > Aha, hier hat also jemand (ich) NFS-Root ausgewählt. Klar, daß
    > dazu auch das NFS-Kernelmodul ausgewählt werden muß. Jetzt hat
    > dieser Jemand aber bspw. eine 7270_v1 mit Kernel 2.6.19.2. Das
    > Problem liegt auf der Hand: Entweder sollte beim NFS-Modul dieser
    > Kernel mit in die Dependencies-Liste, oder für diesen Kernel
    > sollten alle NFS-relevanten Sachen deaktiviert werden. Alles
    > andere ist ein Widerspruch, und der wird moniert von *Kconfig*.
    > Was in diesem Fall sachlich zutreffend ist, weiß ich momentan
    > nicht, dafür war ich zu lange zu weit weg von der Entwicklung.

<!-- -->

-   **Ticket #1532 "Kommentar 24 für Ticket #1532":
    Liste aktueller Warnungen mit Erläuterungen zu Ursachen und
    möglichen Lösungen**
-   **Ticket #1532 "Kommentar 31 für Ticket #1532":
    konkretes Beispiel einer von Alexander Kriegisch eingecheckten
    Problembehebung**

    > Ich versuche es einfach statt in Prosa mal schematisch:
    > :-)
    >
    > ::: {.code}
    >     FREETZ_PACKAGE_DAVFS2
    >         select FREETZ_REMOVE_WEBDAV if FREETZ_HAS_AVM_WEBDAV
    >
    >     FREETZ_REMOVE_WEBDAV
    >         depends on FREETZ_HAS_AVM_WEBDAV
    >
    >     FREETZ_HAS_AVM_WEBDAV
    >         depends on FREETZ_TYPE_FON_WLAN_7240 || ...
    > :::
    >
    > Das sieht mir sauber genug aus, obwohl das "if
    > FREETZ_HAS_AVM_WEBDAV" - da gebe ich Dir recht - in Deinem
    > Sinne doppelt ist. Aber es sagt dafür genauer, was Du wirklich tun
    > willst (man kann die Konfigurationsanweisung diesmal wirklich wie
    > Prosa lesen): Wähle den Remove-Patch aus, falls es überhaupt etwas
    > zu entfernen gibt. Ich denke, das macht es hinreichend klar und
    > dokumentiert nochmals, was gewollt ist. Zudem vermeidet es die
    > Warnung nach dem Speichern der Konfiguration. Ohne das *If* würde
    > die Warnung erscheinen.

<!-- -->

-   **Ticket #1532 "Kommentar 54 für Ticket #1532":
    verallgemeintertes "Kochrezept" zur Problembehebung bei
    Remove-Patches**

    > Ich weise nochmals auf meinen Kommentar \#31 hin, aus dem man im
    > Grunde sehr schön ablesen kann, wie einfach, elegant und lesbar
    > man viele Situationen beheben kann:
    >
    > ::: {.code}
    >     FREETZ_PACKAGE_FOO
    >         select FREETZ_REMOVE_MY_FEATURE if FREETZ_HAS_AVM_MY_FEATURE
    >
    >     FREETZ_REMOVE_MY_FEATURE
    >         depends on FREETZ_HAS_AVM_MY_FEATURE
    >
    >     FREETZ_HAS_AVM_MY_FEATURE
    >         depends on FREETZ_TYPE_A || FREETZ_TYPE_B || ...
    > :::
    >
    > **Kochrezept für Remove-Patches (RP):**
    >
    > -   Automatische RP-Auswahl absichern durch
    >     `if FREETZ_HAS_AVM_MY_FEATURE`
    > -   RP-Sichtbarkeit abhängig machen durch
    >     `depends on FREETZ_HAS_AVM_MY_FEATURE`
    > -   Durch RP entfernbares Feature abhängig machen von Hardware
    >     oder Firmware usw. durch `depends on FREETZ_TYPE_A`

<!-- -->

-   **Ticket #1532 "Kommentar 55 für Ticket #1532":
    weitere Erläuterungen zur Umsetzung des Kochrezepts**

    > Replying to oliver:
    >
    > > Wo ist der Sinn darin eine dependency herauszunehmen, die (bis
    > > auf wenige Fälle) richtig ist?
    >
    > Jetzt habe ich mir den ersten Patch
    > doch schnell mal angeschaut. Es ist weder korrekt, sie so drin zu
    > lassen, wenn sie auch nur in wenigen Fällen falsch ist, noch, sie
    > ersatzlos zu streichen, wenn unsinnige Optionen dafür in neuen,
    > falschen Fällen angezeigt werden. Was hingegen Sinn (und etwas
    > Mühe) machen würde, wäre, mein Kochrezept anzuwenden und neue
    > Variablen FREETZ_HAS_AVM_AURA_USB, FREETZ_HAS_AVM_PRINTSERV
    > und FREETZ_HAS_AVM_RUNCLOCK anzulegen. Die könnte
    > FREETZ_HAS_USB_HOST ja von mir aus in den Fällen, wo es keine
    > gegenteiligen Erkenntnisse gibt, automatisch auswählen. Sobald
    > aber auch nur eine einzige Ausnahme bekannt ist, ist eine
    > Box-Liste beim jeweiligen FREETZ_HAS_AVM_\* zu hinterlegen. Die
    > Remove-Patches sollten immer von FREETZ_HAS_AVM_\* abhängen,
    > nie von einem billigen Ersatz der nur *fast* immer funktioniert.
    >
    > Das ist keine Kritik i.S.v. "das hättest Du aber vorher wissen
    > sollen", denn die Erkenntnisse sind ja relativ neu und m.E. ein
    > Segen des neuen *Kconfig*. Ich will durch meine Hinweise den
    > anderen Entwicklern Hilfe zur Selbsthilfe geben.
    >
    > Ergänzung: Es ist auch sowas vorstellbar:
    >
    > ::: {.code}
    >     FREETZ_HAS_AVM_MY_FEATURE
    >         depends on FREETZ_HAS_USB_HOST && !(FREETZ_TYPE_A || FREETZ_TYPE_B)
    > :::
    >
    > So hält man die Boxen-Liste klein, indem man einfach klar sagt,
    > was Sache ist. Es ist wieder fast wie Prosa lesbar: "Zeig das
    > AVM-Feature X an, wenn die Box einen USB-Host hat, außer in den
    > Ausnahmefällen A und B."

### Syntax-Fehler in MK-Dateien finden

Wir sehen einen Fehler wie diesen:

```
	$ make menuconfig

	Config.in.cache:4951: syntax error
	Config.in.cache:4950: unknown option "xconfig"
	Config.in.cache:4951:warning: prompt redefined
	make: *** [menuconfig] Error 1
```

Gemäß Beschreibung in
[r8466](https://trac.boxmatrix.info/freetz-ng/changeset/8466)
gibt es zwei Wege, bei einem von `make menuconfig` angezeigten
Syntax-Fehler schnell die fehlerhafte Stelle zu finden:

1.  In `Config.cache.in` direkt zu der Fehlerzeile 4950 springen, die
    auf der Konsole angezeigt wurde. Von dort aus rückwärts(!) suchen
    nach `INCLUDE_BEGIN` - voilà, dort steht der Dateiname, wo die
    fehlerhafte MK zu finden ist.
2.  `make menuconfig-nocache` aufrufen und die problematische Datei
    (*make/davfs2/Config.in*) direkt von der Konsole ablesen:

    ```
		$ make menuconfig-nocache

		make/davfs2/Config.in:2: syntax error
		make/Config.in:84: missing end statement for this entry
		Config.in:851: missing end statement for this entry
		make/davfs2/Config.in:1: invalid statement
		make/davfs2/Config.in:2: unexpected option "bool"
		make/davfs2/Config.in:3: unexpected option "select"
		make/davfs2/Config.in:4: unexpected option "select"
		make/davfs2/Config.in:5: unexpected option "select"
		make/davfs2/Config.in:6: unexpected option "select"
		make/davfs2/Config.in:7: unexpected option "select"
		make/davfs2/Config.in:8: unexpected option "select"
		make/davfs2/Config.in:9: unexpected option "default"
		make/davfs2/Config.in:10: invalid statement
		make/davfs2/Config.in:11: unknown statement "davfs"
		make/davfs2/Config.in:12: unknown statement "WebDAV"
		make/davfs2/Config.in:13: unknown statement "HTTP"
		make/davfs2/Config.in:14: unknown statement "resources"
		make/Config.in:199: unexpected end statement
		Config.in:862: unexpected end statement
		make: *** [menuconfig-nocache] Error 1
    ```

### Syntax-Hervorhebung für MK-Dateien

Gemäß tools/developer/kconfig.pygments.patch
habe ich (Alexander Kriegisch, kriegaex) zunächst einen sog.
[Lexer](http://de.wikipedia.org/wiki/Lexikalischer_Scanner)
für [Pygments](http://pygments.org) gebaut (siehe
auch
[Pygments-Doku](http://pygments.org/docs/lexerdevelopment/)),
welcher es ermöglicht, MK-Dateien mit Syntax-Hervorhebung zu versehen.
*Pygments* wird von
[Trac](http://trac.edgewall.org), also dem System,
auf welchem unser Wiki und der Repository Browser basieren, automatisch
benutzt, sofern es installiert ist.

*Trac* erkennt den MIME-Typ einer Datei aber nur aufgrund der Endung
(also z.B. *.py, .sh, .pl, .c, .h*) oder aufgrund Infos wie
[Shebang](http://de.wikipedia.org/wiki/Shebang)
oder *Vi-/Emacs*-Header, und das ist ein Problem bei MK-Dateien, da es
keine standardisierte Dateiendung im Allgemeinen und auch nicht bei uns
im Projekt gibt. Unsere einzige Chance ist es, den Wildwuchs an
Dateinamen (z.B. *Config.in, external.in, standard-modules.in,
external.in.libs*) so im Zaum zu halten, daß man mit [Regex
Matching](http://de.wikipedia.org/wiki/Regul%C3%A4rer_Ausdruck)
die entsprechenden Dateien identifizieren kann. Das ist Stand heute
möglich, allerdings beherrscht *Trac* von Haus aus kein Regex Matching,
weswegen tools/developer/mime_map_patterns.trac.patch
notwendig wird. *(Anm.: Bevor es Patch 2 gab, war es notwendig, in SVN
die Eigenschaft `svn:mime-type` für jede MK-Datei manuell zu setzen, was
inzwischen zum Glück obsolet ist, aber auch nicht schaden würde.)*

Auf unserem Webserver sind beide Patches nebst der notwendigen
Konfiguration in `trac.ini` aktiv, so daß MK-Dateien aus dem
SVN-Repository automatisch mit Syntax-Hervorhebung versehen werden.

Noch ein kleiner Tip: Wie man Syntax Highlighting im *Trac*-Wiki direkt
in Code-Blocks einsetzt, sieht man hier direkt im Artikel für MK- und
Shell-Code: Entweder man erwähnt am Anfang des Code-Blocks mit führendem
Shebang den MIME-Typ (`text/x-kconfig`, übrigens selbst erfunden und
kein allgemeiner Standard) oder das in `trac.ini` konfigurierte
Schlüsselwort `kconfig`, also in etwa so:

```
	{{{
	#!text/x-kconfig
	... MK-Code ...
	}}}
```

Oder so:

```
	{{{
	#!kconfig
	... MK-Code ...
	}}}
```


