#!/bin/sh


. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$FHEM_ENABLED" yes:auto "*":man
check "$FHEM_DEMOMODE" yes:demomode
check "$FHEM_DBMODE" yes:dbmode

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"FHEM Seite" en:"FHEM page")'
cat << EOF
<p>$(lang de:"Deine Hausautomatisierungsseite kann" en:"You can open your home automation site") <b><a style='font-size:14px;' target='_blank' href=http://`ifconfig lan | grep "inet addr" | cut -d: -f2 | cut -d' ' -f1`:8083/>$(lang de:"hier" en:"here")</a></b>$(lang de:" ge&ouml;ffnet werden." en:".")<p>
EOF
sec_end

sec_begin '$(lang de:"Zentrale Konfiguration" en:"Core configuration")'
cat << EOF
$(lang de:"Wenn kein externes Verzeichnis konfiguriert ist, dann wird ein internes verwendet, wo nur die Konfiguration gesichert wird, Logs werden beim Neustart gel&ouml;scht." en:"When you do not use an external drive, only the configuration is restored, the log files may get lost on restart")</label></p>
<hr>
$(lang de:"Benutze FHEM im folgendem Verzeichnis auf einem externen Laufwerk" en:"Use FHEM in below directoryon a external drive")</label></p>
<p style="font-size:10px;">$(lang de:"Bitte gib hier den Speicherort f&uuml;r fhem Dateien an. Falls das Verzeichnis leer ist wird automatisch die richtige Dateistruktur erstellt. Dieses Verzeichnis wird alle Dateien von fhem enthalten, welche via einem Webfrontend bearbeitet werden muss." en:"Please provide the storage location for fhem files. In case the directory is empty the proper directory structure will be created. This directory will contain all files for fhem which must be modified via a web frontend.")</p>
<p> $(lang de:"Verzeichnis f&uuml;r fhem" en:"Directory for fhem"): <input type="text" name="location" size="45" maxlength="255" value="$(html "$FHEM_LOCATION")"></p>
<p> $(lang de:"Verzeichnis f&uuml;r Log-Dateien" en:"Directory for log-files"): <input type="text" name="logextern" size="38" maxlength="255" value="$(html "$FHEM_LOGEXTERN")"></p>
EOF
cat << EOF
<hr>
<p><input type="hidden" name="demomode" value="no">
<input id="i1" type="checkbox" name="demomode" value="yes"$demomode_chk><label for="i1">
$(lang de:"Fhem Demo/Test Modus setzen" en:"set fhem demo/test mode")</label></p>
<hr>
<p><input type="hidden" name="dbmode" value="no">
<input id="j1" type="checkbox" name="dbmode" value="yes"$dbmode_chk><label for="j1">
$(lang de:"Fhem ConfigDB Modus setzen" en:"set fhem ConfigDB mode")</label></p>
$(lang de:"F&uuml;r den ConfigDB Modus sollte ein externes Laufwerk benutzt werden, die Konfiguration wird in diesem Modus nicht intern gespeichert." en:"In ConfigDB mode you should use an external drive, the configuration in ConfigDB mode will not be stored in internal memory.")</label></p>
EOF
sec_end