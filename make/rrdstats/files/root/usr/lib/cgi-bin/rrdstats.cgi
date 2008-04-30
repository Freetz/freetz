#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''; log_protoc_chk=''
notlazym_chk=''; notlazys_chk=''; cpu100perc_chk=''
logarithm1_chk=''; logarithm2_chk=''; logarithm3_chk=''; logarithm4_chk='';
xchg_rxtx1_chk=''; xchg_rxtx2_chk=''; xchg_rxtx3_chk=''; xchg_rxtx4_chk='';

if [ "$RRDSTATS_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$RRDSTATS_XCHGUPDOWN" = "yes" ]; then xchgupdown_chk=' checked'; fi
if [ "$RRDSTATS_NOTLAZYM" = "yes" ]; then notlazym_chk=' checked'; fi
if [ "$RRDSTATS_NOTLAZYS" = "yes" ]; then notlazys_chk=' checked'; fi
if [ "$RRDSTATS_LOGARITHM1" = "yes" ]; then logarithm1_chk=' checked'; fi
if [ "$RRDSTATS_LOGARITHM2" = "yes" ]; then logarithm2_chk=' checked'; fi
if [ "$RRDSTATS_LOGARITHM3" = "yes" ]; then logarithm3_chk=' checked'; fi
if [ "$RRDSTATS_LOGARITHM4" = "yes" ]; then logarithm4_chk=' checked'; fi
if [ "$RRDSTATS_XCHG_RXTX1" = "yes" ]; then xchg_rxtx1_chk=' checked'; fi
if [ "$RRDSTATS_XCHG_RXTX2" = "yes" ]; then xchg_rxtx2_chk=' checked'; fi
if [ "$RRDSTATS_XCHG_RXTX3" = "yes" ]; then xchg_rxtx3_chk=' checked'; fi
if [ "$RRDSTATS_XCHG_RXTX4" = "yes" ]; then xchg_rxtx4_chk=' checked'; fi
if [ "$RRDSTATS_CPU100PERC" = "yes" ]; then cpu100perc_chk=' checked'; fi

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1">Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2">Manuell</label>
</p>
EOF

sec_end
sec_begin 'Anzeigen'
cat << EOF
<ul>
<li><a href="/cgi-bin/pkgstatus.cgi?pkg=rrdstats&cgi=rrdstats/stats">Statistiken anzeigen</a></li>
EOF

sec_end
sec_begin 'Einstellungen'

cat << EOF
<p>Tempor&auml;res Verzeichnis:&nbsp;<input type="text" name="rrdtemp" size="45" maxlength="255" value="$(html "$RRDSTATS_RRDTEMP")"></p>
<p>Persistentes Verzeichnis:&nbsp;<input type="text" name="rrddata" size="45" maxlength="255" value="$(html "$RRDSTATS_RRDDATA")"></p>
<p>Aufzeichnungsintervall in Sekunden:&nbsp;<input type="text" name="interval" size="3" maxlength="9" value="$(html "$RRDSTATS_INTERVAL")"></p>
<p>
Dimensionsverh&auml;ltnis der Graphen: 
<input type="text" name="dimensionx" size="3" maxlength="9" value="$(html "$RRDSTATS_DIMENSIONX")">
:
<input type="text" name="dimensiony" size="3" maxlength="9" value="$(html "$RRDSTATS_DIMENSIONY")">
</p>
<p>
Periode der Hauptseite:&nbsp;<input type="text" name="periodmain" size="2" maxlength="4" value="$(html "$RRDSTATS_PERIODMAIN")">
der Unterseiten:&nbsp;<input type="text" name="periodssub" size="22" maxlength="99" value="$(html "$RRDSTATS_PERIODSSUB")">
</p>
<p>
Graphen immer neu generieren (not lazy):
<input type="hidden" name="notlazym" value="no">
<input id="l1" type="checkbox" name="notlazym" value="yes"$notlazym_chk><label for="l1">Hauptseite</label>
<input type="hidden" name="notlazys" value="no">
<input id="l2" type="checkbox" name="notlazys" value="yes"$notlazys_chk><label for="l2">Unterseiten</label>
</p>
<p>
Maximum des Graphen der CPU-Nutzung auf 100 Prozent festlegen:
<input type="hidden" name="cpu100perc" value="no">
<input id="c1" type="checkbox" name="cpu100perc" value="yes"$cpu100perc_chk><label for="c1"></label>
</p>
EOF

sec_end
sec_begin 'Interfaces'

cat << EOF

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bezeichnung
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Interface
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Maximal
&nbsp;&nbsp;&nbsp;logarithm.
&nbsp;&nbsp;Up/Down

<p>
Interface 1:
&nbsp;<input type="text" name="nice_name1" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME1")">
&nbsp;<input type="text" name="interface1" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE1")">
&nbsp;<input type="text" name="max_graph1" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH1")">
<input type="hidden" name="logarithm1" value="no">
<input id="s1" type="checkbox" name="logarithm1" value="yes"$logarithm1_chk><label for="s1">aktiviert</label>
<input type="hidden" name="xchg_rxtx1" value="no">
<input id="x1" type="checkbox" name="xchg_rxtx1" value="yes"$xchg_rxtx1_chk><label for="x1">tauschen</label>
</p>

<p>
Interface 2: 
&nbsp;<input type="text" name="nice_name2" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME2")">
&nbsp;<input type="text" name="interface2" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE2")">
&nbsp;<input type="text" name="max_graph2" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH2")">
<input type="hidden" name="logarithm2" value="no">
<input id="s2" type="checkbox" name="logarithm2" value="yes"$logarithm2_chk><label for="s2">aktiviert</label>
<input type="hidden" name="xchg_rxtx2" value="no">
<input id="x2" type="checkbox" name="xchg_rxtx2" value="yes"$xchg_rxtx2_chk><label for="x2">tauschen</label>
</p>

<p>
Interface 3:
&nbsp;<input type="text" name="nice_name3" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME3")">
&nbsp;<input type="text" name="interface3" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE3")">
&nbsp;<input type="text" name="max_graph3" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH3")">
<input type="hidden" name="logarithm3" value="no">
<input id="s3" type="checkbox" name="logarithm3" value="yes"$logarithm3_chk><label for="s3">aktiviert</label>
<input type="hidden" name="xchg_rxtx3" value="no">
<input id="x3" type="checkbox" name="xchg_rxtx3" value="yes"$xchg_rxtx3_chk><label for="x3">tauschen</label>
</p>

<p>
Interface 4:
&nbsp;<input type="text" name="nice_name4" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME4")">
&nbsp;<input type="text" name="interface4" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE4")">
&nbsp;<input type="text" name="max_graph4" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH4")">
<input type="hidden" name="logarithm4" value="no">
<input id="s4" type="checkbox" name="logarithm4" value="yes"$logarithm4_chk><label for="s4">aktiviert</label>
<input type="hidden" name="xchg_rxtx4" value="no">
<input id="x4" type="checkbox" name="xchg_rxtx4" value="yes"$xchg_rxtx4_chk><label for="x4">tauschen</label>
</p>


<FONT SIZE=-2>
Interfaces: cpmac0 (DSL-Modem), wan (ATA-Modus), lan (Netzwerk), usbrndis (USB), ...
<br>
Maximal: Maximale Bandbreite in Megabit/Sekunde, "0" für automatische Zuweisung
</FONT>

EOF

sec_end
