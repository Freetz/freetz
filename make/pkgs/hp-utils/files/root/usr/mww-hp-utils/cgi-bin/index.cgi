#!/bin/sh


. /usr/lib/libmodcgi.sh

[ -r "/mod/etc/conf/hp-utils.cfg" ] && . /mod/etc/conf/hp-utils.cfg

stat_bar() {
	percent=$1; let bar="percent*2"; let grey="(100-percent)*2"
	echo '<img src="/images/green.png" width="'"$bar"'" height="13" border="0" alt=""><img src="/images/grey.png" width="'"$grey"'" height="13" border="0" alt="">'
}

status_text() {
	local status=$1
	case $status in
	    1000) echo "$(lang de:"im Leerlauf" en:"idle")" ;;
	    1001) echo "$(lang de:"besch&auml;ftigt" en:"busy")" ;;
	    1002) echo "$(lang de:"druckt" en:"printing")" ;;
	    1003) echo "$(lang de:"Ausschalten" en:"turning off")" ;;
	    1004) echo "$(lang de:"druckt Bericht" en:"report printing")" ;;
	    1005) echo "$(lang de:"Abbrechen" en:"canceling")" ;;
	    1006) echo "$(lang de:"angehalten" en:"I/O stall")" ;;
	    1007) echo "$(lang de:"wartet auf Trocknung" en:"dry wait time")" ;;
	    1008) echo "$(lang de:"Patronenwechsel" en:"pen change")" ;;
	    1009) echo "$(lang de:"Papier einlegen" en:"out of paper")" ;;
	    1010) echo "$(lang de:"Banner-Auswurf" en:"banner eject")" ;;
	    1011) echo "banner mismatch" ;;
	    1012) echo "photo mismatch" ;;
	    1013) echo "duplex mismatch" ;;
	    1014) echo "$(lang de:"Papierstau" en:"media jam")" ;;
	    1015) echo "carriage stall" ;;
	    1016) echo "paper stall" ;;
	    1017) echo "$(lang de:"Druckpatronen-Fehler" en:"pen failure")" ;;
	    1018) echo "$(lang de:"schwerer Fehler" en:"hard error")" ;;
	    1019) echo "$(lang de:"Herunterfahren" en:"power down")" ;;
	    1020) echo "front panel test" ;;
	    1021) echo "clean out tray missing" ;;
	    1022) echo "output bin full" ;;
	    1023) echo "media size mismatch" ;;
	    1024) echo "manual duplex block" ;;
	    1025) echo "service stall" ;;
	    1026) echo "$(lang de:"Tinte/Toner leer" en:"out of ink/toner")" ;;
	    1027) echo "lio error" ;;
	    1028) echo "pump stall" ;;
	    1029) echo "$(lang de:"Schacht 2 fehlt" en:"tray 2 missing")" ;;
	    1030) echo "$(lang de:"Duplexeinheit fehlt" en:"duplexer missing")" ;;
	    1031) echo "$(lang de:"hinterer Schacht fehlt" en:"rear tray missing")" ;;
	    1032) echo "pen not latched" ;;
	    1033) echo "$(lang de:"sehr niedriger Batteriestand" en:"battery very low")" ;;
	    1034) echo "spittoon full" ;;
	    1035) echo "$(lang de:"Ausgabeschacht geschlossen" en:"output tray closed")" ;;
	    1036) echo "$(lang de:"manuelle Zufuhr blockier" en:"manual feed blocked")" ;;
	    1037) echo "$(lang de:"hintere Zufuhr blockiert" en:"rear feed blocked")" ;;
	    1038) echo "$(lang de:"Schacht 2: Papier einlegen" en:"tray 2 out of paper")" ;;
	    1039) echo "unable to load from locked tray" ;;
	    1040) echo "$(lang de:"keine HP-Tinte" en:"non hp ink")" ;;
	    1041) echo "pen calibration resume" ;;
	    1042) echo "media type mismatch" ;;
	    1043) echo "custom media mismatch" ;;
	    1044) echo "$(lang de:"Druckkopfreinigung" en:"pen cleaning")" ;;
	    1045) echo "$(lang de:"Patronen&uuml;berpr&uuml;fung" en:"pen checking")" ;;
	       *) echo "$(lang de:"unbekannt" en:"unknown")" ;;
	esac
}

type_text() {
	local type=$1
	case $type in
	     1) echo "$(lang de:"Schwarze" en:"Black")" ;;
	     2) echo "$(lang de:"Dreifarb" en:"Tri-color")" ;;
	     3) echo "Photo" ;;
	     4) echo "Cyan" ;;
	     5) echo "Magenta" ;;
	     6) echo "$(lang de:"Gelbe" en:"Yellow")" ;;
	     7) echo "$(lang de:"Cyan Photo" en:"Photo cyan")" ;;
	     8) echo "$(lang de:"Magenta Photo" en:"Photo magenta")" ;;
	     9) echo "$(lang de:"Gelbe Photo" en:"Photo yellow")" ;;
	    10) echo "$(lang de:"Graue Photo" en:"Photo gray")" ;;
	    11) echo "$(lang de:"Blaue Photo" en:"Photo blue")" ;;
	    12) echo "$(lang de:"Druckkopf" en:"Print head")" ;;
	    13) echo "$(lang de:"Magenta und cyan Photo" en:"Photo magenta and photo cyan")" ;;
	    14) echo "$(lang de:"Schwarze und gelbe" en:"Black and yellow")" ;;
	    15) echo "$(lang de:"Cyan- und Magenta" en:"Cyan and magenta")" ;;
	    16) echo "$(lang de:"Hellgraue und schwarze Photo" en:"Light gray and photo black")" ;;
	    17) echo "$(lang de:"Hellgraue" en:"Light gray")" ;;
	    18) echo "$(lang de:"Mittelgraue" en:"Medium gray")" ;;
	    19) echo "$(lang de:"Graue Photo" en:"Photo gray")" ;;
	     *) echo "unknown" ;;
	esac
}

health_text() {
	local health=$1
	case $health in
	    0) echo "$(lang de:"OK" en:"Good/OK")" ;;
	    1) echo "$(lang de:"falsch installiert" en:"misinstalled")" ;;
	    2) echo "incorrect" ;;
	    3) echo "failed" ;;
	    4) echo "overtemp" ;;
	    5) echo "charging" ;;
	    6) echo "discharging" ;;
	    *) echo "unknown" ;;
	esac
}

cgi_begin 'hp-utils'

sel=' style="background-color: #bae3ff;"'
cat << EOF
<div class="menu">
<div$sel><a href="/cgi-bin/index.cgi">Status</a></div>
<div><a href="/cgi-bin/maint.cgi">$(lang de:"Wartung" en:"Maintenance")</a></div>
<div class="su"><a href="/cgi-bin/maint.cgi?action=clean">$(lang de:"Druckkopfreinigung" en:"Print Cartridge Cleaning")</a></div>
<div class="su"><a href="/cgi-bin/maint.cgi?action=align">$(lang de:"Druckkopfausrichtung" en:"Print Cartridge Alignment")</a></div>
</div>
EOF

sec_begin Status
if [ -z "$HP_UTILS_URI" ]; then
	echo "<p>$(lang de:"Drucker nicht konfiguriert." en:"Printer not configured.")</p>"
else
	status=$(hp-status --device "$HP_UTILS_URI" --web-interface 2>/dev/null)
	ret=$?
	case $ret in
	    3) echo "<p>$(lang de:"Drucker nicht gefunden." en:"Printer not found.")</p>" ;;
	    4) echo "<p>$(lang de:"Nicht unterst&uuml;tzter Drucker." en:"Unsupported on this printer.")</p>" ;;
	    5) echo "<p>$(lang de:"F&uuml;r diesen Drucker (noch) nicht implementiert." en:"Not (yet) implemented for this printer.")</p>" ;;
	    0) echo -n "$(status_text $((status)))" ;;
	    *) echo "<p>$(lang de:"I/O-Fehler." en:"I/O-Error.")</p>" ;;
	esac
fi
sec_end

sec_begin "$(lang de:"Verbrauchsmaterialien" en:"Supplies")"
if [ -z "$HP_UTILS_URI" ]; then
	echo "<p>$(lang de:"Drucker nicht konfiguriert." en:"Printer not configured.")</p>"
else
	_IFS=$IFS
	IFS="
	"
	levels=$(hp-levels --device "$HP_UTILS_URI" --web-interface 2>/dev/null)
	ret=$?
	case $ret in
	    3) echo "<p>$(lang de:"Drucker nicht gefunden." en:"Printer not found.")</p>" ;;
	    4) echo "<p>$(lang de:"Nicht unterst&uuml;tzter Drucker." en:"Unsupported on this printer.")</p>" ;;
	    5) echo "<p>$(lang de:"F&uuml;r diesen Drucker (noch) nicht implementiert." en:"Not (yet) implemented for this printer.")</p>" ;;
	    0) IFS=" "
		echo "<table>"
		echo $levels | while read id type kind level trigger health; do
			echo "<tr>"
			echo "<td>"
			echo -n "$(type_text $((type)))"
			if [ $kind -eq 3 ]; then
				if [ $type -eq 1 -o $type -eq 6 -o $type -eq 14 -o $type -eq 17 ]; then
					echo "$(lang de:" Patrone" en:" cartridge")"
				else
					echo "$(lang de:"-Patrone" en:" cartridge")"
				fi
			else
				echo " unknown"
			fi
			echo "</td>"
			echo "<td>"
			stat_bar $level
			echo "</td>"
			echo "<td>${level}%</td>"
			echo "<td>"
			echo -n "$(health_text $((health)))"
			echo "</td>"
			echo "</tr>"
		done
		echo "</table>"
	    ;;
	    *) echo "<p>$(lang de:"I/O-Fehler." en:"I/O-Error.")</p>" ;;
	esac
	IFS=$_IFS
fi
sec_end

cgi_end
