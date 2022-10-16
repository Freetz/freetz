#!/bin/sh
# This is the cgi for configuring collectd
# Copyright 2010, 2011 Brian Jensen (Jensen.J.Brian@googlemail.com)

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$COLLECTD_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Statistiken anzeigen" en:"Show statistics")"

cat << EOF
<ul>
<li><a href="$(href status collectd view)">$(lang de:"Statistiken anzeigen" en:"Show statistics")</a></li>
<ul>
EOF

sec_end

sec_begin "$(lang de:"Einstellungen" en:"Settings")"
cat << EOF
<p>
$(lang de:"Verzeichnis f&uuml;r Graphen" en:"Graph folder"):&nbsp;<input type="text" name="graphdir" size="45" maxlength="255" value="$(html "$COLLECTD_GRAPHDIR")">
</p>
<p>
$(lang de:"Dimensionsverh&auml;ltnis der Graphen" en:"Graph dimensions ratio"):
<input type="text" name="dimensionx" size="3" maxlength="9" value="$(html "$COLLECTD_DIMENSIONX")">
:
<input type="text" name="dimensiony" size="3" maxlength="9" value="$(html "$COLLECTD_DIMENSIONY")">
</p>
<p>
$(lang de:"Periode der Hauptseite" en:"Period of main graph"):&nbsp;<input type="text" name="periodmain" size="2" maxlength="4" value="$(html "$COLLECTD_PERIODMAIN")">
$(lang de:"der Unterseiten" en:"sub-pages"):&nbsp;<input type="text" name="periodssub" size="18" maxlength="99" value="$(html "$COLLECTD_PERIODSSUB")">
</p>
<p>
$(lang de:"Zeige nur folgende Hosts auf der Hauptseite" en:"Show only the following hosts on the main page"):&nbsp;<input type="text" name="mainpage_hosts" size="40" maxlength="255" value="$(html "$COLLECTD_MAINPAGE_HOSTS")">
</p>
<p>
$(lang de:"Zeige nur folgende Plugins auf der Hauptseite" en:"Show only the following plugins on the main page"):&nbsp;<input type="text" name="mainpage_plugins" size="40" maxlength="255" value="$(html "$COLLECTD_MAINPAGE_PLUGINS")">
</p>

EOF

sec_end

sec_begin "$(lang de:"Fortgeschrittene Einstellungen" en:"Expert Settings")"
cat << EOF
<p>
$(lang de:"Eigenes Skript f&uuml;r die Generierung der Graphen" en:"Custom script for graph generation"):&nbsp;<input type="text" name="graph_script" size="40" maxlength="255" value="$(html "$COLLECTD_GRAPH_SCRIPT")">
</p>

EOF

sec_end
