# libmodcgi.sh

Diese Bibliothek dient der Erzeugung von Webseiten innerhalb des
Freetz-Webinterface. Einzubinden durch

```
source /usr/lib/libmodcgi.sh
```

### cgi

**Diese Schnittstelle ist in Entwicklung und kann sich täglich ändern.**

Mithilfe der Funktion `cgi` können verschiedene Einstellungen für die
aktuelle Seite vorgenommen werden. `cgi` darf nur vor `cgi_begin`
aufgerufen werden.

Die Optionen sind im Einzelnen:

`--style=URI`

> Das CSS-Stylesheet an der Adresse `URI` wird zusätzlich eingebunden.
> Diese Option kann mehrfach verwendet werden.

> Relative URLs werden relativ zu `/style/` im Freetz-Webinterface
> ausgewertet. Sollte ein Stylesheet also im Dateisystem unter
> `/usr/share/style/pkg/status.css` abgelegt sein, so kann es über
> `--style=pkg/status.css` eingebunden werden.

`--id=ID`

> Das body-Tag der Seite erhält diese ID; die ID dient außerdem der
> Auswahl des aktiven Menüpunkts in der Navigation.

`--help=PATH`

> Ein Pfad (beginnend mit "/"), der die Hilfe-Seite zu der aktuellen
> Seite angibt. (Für das Haupt-Freetz-Interface wird dieser Pfad
> momentan an
> [http://trac.freetz.org/wiki](http://trac.freetz.org/wiki)
> angehängt.)

### cgi_begin

Startet eine HTML-Seite im Freetz-Stil. (Vom HTTP-Header über den
HTML-Header bis zu Navigationselementen und ähnlichem wird alles
geschrieben, was an den Anfang einer Seite gehört.)

Alle Seiten im Freetz-Webinterface sind momentan in ISO-8859-1 (Latin 1)
kodiert.

Aufruf:

```
cgi_begin TITLE
```

-   TITEL ist der bereits HTML-kodierte Titel der Seite

### cgi_end

Schließt eine HTML-Seite im Freetz-Stil ab.

### sec_begin

Startet einen Abschnitt mit dem Titel TITLE. Wie ein "Abschnitt" im
Detail in der HTML-Ausgabe umgesetzt wird, obliegt dem gewählten Skin;
garantiert wird jedoch ein umgebendes `<div class="section">`

```
sec_begin TITLE [ID]
```

Optional kann eine ID angegeben werden, um sich auf den Abschnitt
beziehen zu können. Auf HTML-Ebene wird dies die ID des genannten
div-Elements.

### sec_end

Beendet einen Abschnitt.

### html

Diese Funktion HTML-kodiert ihre Eingaben. Kurze Eingaben können als
Argument übergeben werden, bei längeren sollte `html` als Filter benutzt
werden:

```
    echo "<input value='$(html "$VALUE")'> ..."
    log_output | html
```

### check, select

TODO

### href

Erzeugt einen Link zu einer dynamisch registrierten Seite im
Freetz-Webinterface: Die Argumente sind denen von `modreg` ähnlich:

```
href file <pkg> <id>
href extra <pkg> <cgi-name>
href status <pkg> [<cgi-name>]
href cgi <pkg> [<key-value>]...
```

Typischer Einsatz in einem Paket foo:

```
    cat << EOF
      <a href="$(href file foo advanced)">Konfigurationsdatei bearbeiten</a>
    EOF
```

(wenn die Datei vorher per `modreg file foo advanced ...` registriert
wurde.)

### back_button

TODO

### sec_level

TODO

### stat_bar

TODO

### cgi_param

TODO

### cgi_error, print_error

```
cgi_error MESSAGE
print_error MESSAGE
```

`cgi_error` erzeugt eine komplette Fehlerseite (inkl.
cgi_begin/cgi_end) mit der angegeben Meldung. `print_error` erzeugt
nur die Fehlermeldung und kann innerhalb einer bestehenden Seite genutzt
werden.

### path_info

Splits PATH_INFO into segments at "/"; returns the segments in the
given variables. If there are not more variables than segments, the
final variable will receive the remaining unsplit PATH_INFO.

```
PATH_INFO=/foo/bar/baz
path_info package id rest
```

will set

```
package=foo
id=bar
rest=/baz
```

### valid

Validiert bestimmte Arten von Eingabedaten. Momentan unterstützt:

`valid package PACKAGE`

> Ist wahr, wenn PACKAGE ein gültiger Paket-Name ist.

`valid id NAME`

> Ist wahr, wenn NAME eine gültiger Bezeichner ist (der Dateien, Extras,
> Status-Seiten innerhalb eines Pakets identifiziert)

Die Prüfung ist momentan recht lax (hauptsächlich nur Schutz gegen
Pfadoperationen wie "." und "/" im Namen). Die Ausgabe von `valid`
sollte momentan nicht als Maßstab genommen werden, um gültige Namen zu
konstruieren.


