#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''; log_protoc_chk=''
notlazym_chk=''; notlazys_chk=''; cpu100perc_chk=''
logarithm1_chk=''; logarithm2_chk=''; logarithm3_chk=''; logarithm4_chk='';
xchg_rxtx1_chk=''; xchg_rxtx2_chk=''; xchg_rxtx3_chk=''; xchg_rxtx4_chk='';
uptime_enb_chk=''; savebackup_chk=''; thomsonthg_chk=''; thomsonadv_chk=''

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
if [ "$RRDSTATS_UPTIME_ENB" = "yes" ]; then uptime_enb_chk=' checked'; fi
if [ "$RRDSTATS_SAVEBACKUP" = "yes" ]; then savebackup_chk=' checked'; fi
if [ "$RRDSTATS_THOMSONTHG" = "yes" ]; then thomsonthg_chk=' checked'; fi
if [ "$RRDSTATS_THOMSONADV" = "yes" ]; then thomsonadv_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1">$(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2">$(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Anzeigen" en:"Show statistics")'
cat << EOF
<ul>
<li><a href="/cgi-bin/pkgstatus.cgi?pkg=rrdstats&cgi=rrdstats/stats">$(lang de:"Statistiken anzeigen" en:"Show statistics")</a></li>
EOF

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Settings")'

cat << EOF
<p>$(lang de:"Tempor&auml;res Verzeichnis" en:"Temporary folder"):&nbsp;<input type="text" name="rrdtemp" size="45" maxlength="255" value="$(html "$RRDSTATS_RRDTEMP")"></p>
<p>$(lang de:"Persistentes Verzeichnis" en:"Persistent folder"):&nbsp;<input type="text" name="rrddata" size="45" maxlength="255" value="$(html "$RRDSTATS_RRDDATA")"></p>
<p>$(lang de:"Aufzeichnungsintervall in Sekunden" en:"Log interval in seconds"):&nbsp;<input type="text" name="interval" size="3" maxlength="9" value="$(html "$RRDSTATS_INTERVAL")"></p>
<p>
$(lang de:"Dimensionsverh&auml;ltnis der Graphen" en:"Graph dimensions ratio"): 
<input type="text" name="dimensionx" size="3" maxlength="9" value="$(html "$RRDSTATS_DIMENSIONX")">
:
<input type="text" name="dimensiony" size="3" maxlength="9" value="$(html "$RRDSTATS_DIMENSIONY")">
</p>
<p>
$(lang de:"Periode der Hauptseite" en:"Period of main graph"):&nbsp;<input type="text" name="periodmain" size="2" maxlength="4" value="$(html "$RRDSTATS_PERIODMAIN")">
$(lang de:"der Unterseiten" en:"sub-pages"):&nbsp;<input type="text" name="periodssub" size="22" maxlength="99" value="$(html "$RRDSTATS_PERIODSSUB")">
</p>
<p>
$(lang de:"Graphen immer neu generieren (not lazy)" en:"Always generate new graphs (not lazy)"):
<input type="hidden" name="notlazym" value="no">
<input id="l1" type="checkbox" name="notlazym" value="yes"$notlazym_chk><label for="l1">$(lang de:"Hauptseite" en:"Home")</label>
<input type="hidden" name="notlazys" value="no">
<input id="l2" type="checkbox" name="notlazys" value="yes"$notlazys_chk><label for="l2">$(lang de:"Unterseiten" en:"Sub-pages")</label>
</p>
<p>
<input type="hidden" name="cpu100perc" value="no">
<input id="c1" type="checkbox" name="cpu100perc" value="yes"$cpu100perc_chk><label for="c1"></label>
$(lang de:"Maximum des Graphen der CPU-Nutzung auf 100 Prozent festlegen" en:"Maximum of the CPU utilization graph always at 100%")</p>
<p>
<input type="hidden" name="uptime_enb" value="no">
<input id="u1" type="checkbox" name="uptime_enb" value="yes"$uptime_enb_chk><label for="u1"></label>
$(lang de:"Uptime aufzeichnen und anzeigen" en:"Uptime logging and graphs")</p>
<p>
<input type="hidden" name="savebackup" value="no">
<input id="b1" type="checkbox" name="savebackup" value="yes"$savebackup_chk><label for="b1"></label>
$(lang de:"Backup vor dem Starten anlegen" en:"Backup files before startup")</p>
EOF

sec_end
sec_begin 'Thomson THG'

cat << EOF
<br>

<input type="hidden" name="thomsonthg" value="no">
<input id="t1" type="checkbox" name="thomsonthg" value="yes"$thomsonthg_chk><label for="t1"></label>
$(lang de:"Überwachung des Kabelmodems aktivieren" en:"Observe the cable-modem")
<br>

<input type="hidden" name="thomsonadv" value="no">
<input id="t2" type="checkbox" name="thomsonadv" value="yes"$thomsonadv_chk><label for="t2"></label>
$(lang de:"Zusätzliche Parameter überwachen" en:"Observe more parameters")
<br>

<br>
EOF

sec_end
sec_begin '$(lang de:"Interfaces" en:"Interfaces")'

cat << EOF

<table>
<tr>
	<td>&nbsp;</td>
	<td>$(lang de:"Bezeichnung" en:"Interface label")</td>
	<td>$(lang de:"Interface" en:"Interface")</td>
	<td>$(lang de:"Maximal" en:"Maximum")</td>
	<td>&nbsp;$(lang de:"Logarithm." en:"Logarithm.")</td>
	<td>&nbsp;$(lang de:"Up/Down" en:"Up/Down")</td>
</tr>
<tr>
	<td>Interface 1:</td>
	<td><input type="text" name="nice_name1" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME1")"></td>
	<td><input type="text" name="interface1" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE1")"></td>
	<td><input type="text" name="max_graph1" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH1")"></td>
	<td><input type="hidden" name="logarithm1" value="no"><input id="s1" type="checkbox" name="logarithm1" value="yes"$logarithm1_chk><label for="s1">$(lang de:"aktiviert" en:"activated")</label></td>
	<td><input type="hidden" name="xchg_rxtx1" value="no"><input id="x1" type="checkbox" name="xchg_rxtx1" value="yes"$xchg_rxtx1_chk><label for="x1">$(lang de:"tauschen" en:"inverted")</label></td>
</tr>
<tr>
	<td>Interface 2:</td>
	<td><input type="text" name="nice_name2" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME2")"></td>
	<td><input type="text" name="interface2" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE2")"></td>
	<td><input type="text" name="max_graph2" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH2")"></td>
	<td><input type="hidden" name="logarithm2" value="no"><input id="s2" type="checkbox" name="logarithm2" value="yes"$logarithm2_chk><label for="s2">$(lang de:"aktiviert" en:"activated")</label></td>
	<td><input type="hidden" name="xchg_rxtx2" value="no"><input id="x2" type="checkbox" name="xchg_rxtx2" value="yes"$xchg_rxtx2_chk><label for="x2">$(lang de:"tauschen" en:"inverted")</label></td>
</tr>
<tr>
	<td>Interface 3:</td>
	<td><input type="text" name="nice_name3" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME3")"></td>
	<td><input type="text" name="interface3" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE3")"></td>
	<td><input type="text" name="max_graph3" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH3")"></td>
	<td><input type="hidden" name="logarithm3" value="no"><input id="s3" type="checkbox" name="logarithm3" value="yes"$logarithm3_chk><label for="s3">$(lang de:"aktiviert" en:"activated")</label></td>
	<td><input type="hidden" name="xchg_rxtx3" value="no"><input id="x3" type="checkbox" name="xchg_rxtx3" value="yes"$xchg_rxtx3_chk><label for="x3">$(lang de:"tauschen" en:"inverted")</label></td>
</tr>
<tr>
	<td>Interface 4:</td>
	<td><input type="text" name="nice_name4" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME4")"></td>
	<td><input type="text" name="interface4" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE4")"></td>
	<td><input type="text" name="max_graph4" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH4")"></td>
	<td><input type="hidden" name="logarithm4" value="no"><input id="s4" type="checkbox" name="logarithm4" value="yes"$logarithm4_chk><label for="s4">$(lang de:"aktiviert" en:"activated")</label></td>
	<td><input type="hidden" name="xchg_rxtx4" value="no"><input id="x4" type="checkbox" name="xchg_rxtx4" value="yes"$xchg_rxtx4_chk><label for="x4">$(lang de:"tauschen" en:"inverted")</label></td>
</tr>
</table>

<font size="-2">
$(lang de:"Interfaces: cpmac0 (DSL-Modem), wan (ATA-Modus), lan (Netzwerk), usbrndis (USB), ..." en:"Interfaces: cpmac0 (DSL-Modem), wan (ATA-module), lan (Network), usbrndis (USB), ...")
<br />
$(lang de:"Maximal: Maximale Bandbreite in Megabit/Sekunde, '0' für automatische Zuweisung" en:"Maximum: Maximum bandwidth megabits per second, '0' for automatic allocation")
</font>

EOF

sec_end
