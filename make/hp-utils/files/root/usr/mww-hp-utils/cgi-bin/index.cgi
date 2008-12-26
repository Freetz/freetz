#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

[ -r "/mod/etc/conf/hp-utils.cfg" ] && . /mod/etc/conf/hp-utils.cfg

stat_bar() {
	percent=$1; let bar="percent*2"; let grey="(100-percent)*2"
	echo '<img src="/images/green.png" width="'"$bar"'" height="13" border="0" alt=""><img src="/images/grey.png" width="'"$grey"'" height="13" border="0" alt="">'
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
	if [ $ret -eq 3 ]; then
		echo "<p>$(lang de:"Drucker nicht gefunden." en:"Printer not found.")</p>"
	elif [ $ret -eq 4 ]; then
		echo "<p>$(lang de:"Nicht unterst&uuml;tzter Drucker." en:"Unsupported on this printer.")</p>"
	elif [ $ret -eq 5 ]; then
		echo "<p>$(lang de:"F&uuml;r diesen Drucker (noch) nicht implementiert." en:"Not (yet) implemented for this printer.")</p>"
	elif [ $ret -ne 0 ]; then
		echo "<p>$(lang de:"I/O-Fehler." en:"I/O-Error.")</p>"
	else
		if [ $status -eq 1000 ]; then
			echo -n "$(lang de:"im Leerlauf" en:"idle")"
		elif [ $status -eq 1001 ]; then
			echo -n "$(lang de:"besch&auml;ftigt" en:"busy")"
		elif [ $status -eq 1002 ]; then
			echo -n "$(lang de:"druckt" en:"printing")"
		elif [ $status -eq 1003 ]; then
			echo -n "$(lang de:"Ausschalten" en:"turning off")"
		elif [ $status -eq 1004 ]; then
			echo -n "$(lang de:"druckt Bericht" en:"report printing")"
		elif [ $status -eq 1005 ]; then
			echo -n "$(lang de:"Abbrechen" en:"canceling")"
		elif [ $status -eq 1006 ]; then
			echo -n "$(lang de:"angehalten" en:"I/O stall")"
		elif [ $status -eq 1007 ]; then
			echo -n "$(lang de:"wartet auf Trocknung" en:"dry wait time")"
		elif [ $status -eq 1008 ]; then
			echo -n "$(lang de:"Patronenwechsel" en:"pen change")"
		elif [ $status -eq 1009 ]; then
			echo -n "$(lang de:"Papier einlegen" en:"out of paper")"
		elif [ $status -eq 1010 ]; then
			echo -n "$(lang de:"Banner-Auswurf" en:"banner eject")"
		elif [ $status -eq 1011 ]; then
			echo -n "banner mismatch"
		elif [ $status -eq 1012 ]; then
			echo -n "photo mismatch"
		elif [ $status -eq 1013 ]; then
			echo -n "duplex mismatch"
		elif [ $status -eq 1014 ]; then
			echo -n "$(lang de:"Papierstau" en:"media jam")"
		elif [ $status -eq 1015 ]; then
			echo -n "carriage stall"
		elif [ $status -eq 1016 ]; then
			echo -n "paper stall"
		elif [ $status -eq 1017 ]; then
			echo -n "$(lang de:"Druckpatronen-Fehler" en:"pen failure")"
		elif [ $status -eq 1018 ]; then
			echo -n "$(lang de:"schwerer Fehler" en:"hard error")"
		elif [ $status -eq 1019 ]; then
			echo -n "$(lang de:"Herunterfahren" en:"power down")"
		elif [ $status -eq 1020 ]; then
			echo -n "front panel test"
		elif [ $status -eq 1021 ]; then
			echo -n "clean out tray missing"
		elif [ $status -eq 1022 ]; then
			echo -n "output bin full"
		elif [ $status -eq 1023 ]; then
			echo -n "media size mismatch"
		elif [ $status -eq 1024 ]; then
			echo -n "manual duplex block"
		elif [ $status -eq 1025 ]; then
			echo -n "service stall"
		elif [ $status -eq 1026 ]; then
			echo -n "$(lang de:"Tinte/Toner leer" en:"out of ink/toner")"
		elif [ $status -eq 1027 ]; then
			echo -n "lio error"
		elif [ $status -eq 1028 ]; then
			echo -n "pump stall"
		elif [ $status -eq 1029 ]; then
			echo -n "$(lang de:"Schacht 2 fehlt" en:"tray 2 missing")"
		elif [ $status -eq 1030 ]; then
			echo -n "$(lang de:"Duplexeinheit fehlt" en:"duplexer missing")"
		elif [ $status -eq 1031 ]; then
			echo -n "$(lang de:"hinterer Schacht fehlt" en:"rear tray missing")"
		elif [ $status -eq 1032 ]; then
			echo -n "pen not latched"
		elif [ $status -eq 1033 ]; then
			echo -n "$(lang de:"sehr niedriger Batteriestand" en:"battery very low")"
		elif [ $status -eq 1034 ]; then
			echo -n "spittoon full"
		elif [ $status -eq 1035 ]; then
			echo -n "$(lang de:"Ausgabeschacht geschlossen" en:"output tray closed")"
		elif [ $status -eq 1036 ]; then
			echo -n "$(lang de:"manuelle Zufuhr blockier" en:"manual feed blocked")"
		elif [ $status -eq 1037 ]; then
			echo -n "$(lang de:"hintere Zufuhr blockiert" en:"rear feed blocked")"
		elif [ $status -eq 1038 ]; then
			echo -n "$(lang de:"Schacht 2: Papier einlegen" en:"tray 2 out of paper")"
		elif [ $status -eq 1039 ]; then
			echo -n "unable to load from locked tray"
		elif [ $status -eq 1040 ]; then
			echo -n "$(lang de:"keine HP-Tinte" en:"non hp ink")"
		elif [ $status -eq 1041 ]; then
			echo -n "pen calibration resume"
		elif [ $status -eq 1042 ]; then
			echo -n "media type mismatch"
		elif [ $status -eq 1043 ]; then
			echo -n "custom media mismatch"
		elif [ $status -eq 1044 ]; then
			echo -n "$(lang de:"Druckkopfreinigung" en:"pen cleaning")"
		elif [ $status -eq 1045 ]; then
			echo -n "$(lang de:"Patronen&uuml;berpr&uuml;fung" en:"pen checking")"
		else
			echo -n "$(lang de:"unbekannt" en:"unknown")"
		fi
	fi
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
	if [ $ret -eq 3 ]; then
		echo "<p>$(lang de:"Drucker nicht gefunden." en:"Printer not found.")</p>"
	elif [ $ret -eq 4 ]; then
		echo "<p>$(lang de:"Nicht unterst&uuml;tzter Drucker." en:"Unsupported on this printer.")</p>"
	elif [ $ret -eq 5 ]; then
		echo "<p>$(lang de:"F&uuml;r diesen Drucker (noch) nicht implementiert." en:"Not (yet) implemented for this printer.")</p>"
	elif [ $ret -ne 0 ]; then
		echo "<p>$(lang de:"I/O-Fehler." en:"I/O-Error.")</p>"
	else
		IFS=" "
		echo "<table>"
		echo $levels | while read id type kind level trigger health; do
			echo "<tr>"
			echo "<td>"
			if [ $type -eq 1 ]; then
				echo -n "$(lang de:"Schwarze" en:"Black")"
			elif [ $type -eq 2 ]; then
				echo -n "$(lang de:"Dreifarb" en:"Tri-color")"
			elif [ $type -eq 3 ]; then
				echo -n "Photo"
			elif [ $type -eq 4 ]; then
				echo -n "Cyan"
			elif [ $type -eq 5 ]; then
				echo -n "Magenta"
			elif [ $type -eq 6 ]; then
				echo -n "$(lang de:"Gelbe" en:"Yellow")"
			elif [ $type -eq 7 ]; then
				echo -n "$(lang de:"Cyan Photo" en:"Photo cyan")"
			elif [ $type -eq 8 ]; then
				echo -n "$(lang de:"Magenta Photo" en:"Photo magenta")"
			elif [ $type -eq 9 ]; then
				echo -n "$(lang de:"Gelbe Photo" en:"Photo yellow")"
			elif [ $type -eq 10 ]; then
				echo -n "$(lang de:"Graue Photo" en:"Photo gray")"
			elif [ $type -eq 11 ]; then
				echo -n "$(lang de:"Blaue Photo" en:"Photo blue")"
			elif [ $type -eq 12 ]; then
				echo -n "$(lang de:"Druckkopf" en:"Print head")"
			elif [ $type -eq 13 ]; then
				echo -n "$(lang de:"Magenta und cyan Photo" en:"Photo magenta and photo cyan")"
			elif [ $type -eq 14 ]; then
				echo -n "$(lang de:"Schwarze und gelbe" en:"Black and yellow")"
			elif [ $type -eq 15 ]; then
				echo -n "$(lang de:"Cyan- und Magenta" en:"Cyan and magenta")"
			elif [ $type -eq 16 ]; then
				echo -n "$(lang de:"Hellgraue und schwarze Photo" en:"Light gray and photo black")"
			elif [ $type -eq 17 ]; then
				echo -n "$(lang de:"Hellgraue" en:"Light gray")"
			elif [ $type -eq 18 ]; then
				echo -n "$(lang de:"Mittelgraue" en:"Medium gray")"
			elif [ $type -eq 19 ]; then
				echo -n "$(lang de:"Graue Photo" en:"Photo gray")"
			else
				echo -n "unknown"
			fi
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
			if [ $health -eq 0 ]; then
				echo -n "$(lang de:"OK" en:"Good/OK")"
			elif [ $health -eq 1 ]; then
				echo -n "$(lang de:"falsch installiert" en:"misinstalled")";
			elif [ $health -eq 2 ]; then
				echo -n "incorrect";
			elif [ $health -eq 3 ]; then
				echo -n "failed";
			elif [ $health -eq 4 ]; then
				echo -n "overtemp";
			elif [ $health -eq 5 ]; then
				echo -n "charging";
			elif [ $health -eq 6 ]; then
				echo -n "discharging";
			else
				echo -n "unknown";
			fi
			echo "</td>"
			echo "</tr>"
		done
		echo "</table>"
	fi
	IFS=$_IFS
fi
sec_end

cgi_end
