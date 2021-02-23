#!/bin/sh


. /usr/lib/libmodcgi.sh

DEVICES="$(cat /proc/partitions | sed -nr 's/.*[[:space:]](sd.)$/\1/p' | sort)"
COUNT=0

[ -z "$DEVICES" ] && echo "<br>$(lang de:"Keine Ger&auml;te gefunden." en:"No devices found.")"

if ! which smartctl >/dev/null 2>&1; then
	echo "<h1>$(lang de:"smartctl nicht gefunden." en:"smartctl not found.")</h1>"
	exit
fi

for DEVICE in $DEVICES; do
	let COUNT++
	[ $COUNT -gt 1 ] && echo "<hr><br>"

	DEVICE="/dev/$DEVICE"
	echo "<h1>$(lang de:"Ger&auml;t" en:"Device"): $DEVICE</h1>"

	if ! smartctl $DEVICE >/dev/null 2>&1; then
		echo "$(lang de:"S.M.A.R.T. nicht unterst&uuml;tzt" en:"S.M.A.R.T. not supported").<br><br>"
		continue
	fi

	DATAI="$(smartctl -i $DEVICE 2>/dev/null | sed  -e '1,3d')"
	NAME="$(echo "$DATAI" | sed -rn 's/Device Model: *(.*)/\1/p')"
	SIZE="$(echo "$DATAI" | sed -rn 's/User Capacity:.*\[(.*)]/\1/p')"
	FIRM="$(echo "$DATAI" | sed -rn 's/Firmware Version: *(.*)/\1/p')"
	DATAA="$(smartctl -A $DEVICE 2>/dev/null | sed  -e '1,3d')"
	TGC="$(echo "$DATAA" | sed -rn 's/.*Temperature_Celsius.* ([0-9]*)$/\1/p')"
	PCC="$(echo "$DATAA" | sed -rn 's/.*Power_Cycle_Count.* ([0-9]*)$/\1/p')"
	SSC="$(echo "$DATAA" | sed -rn 's/.*Start_Stop_Count.* ([0-9]*)$/\1/p')"
	POH="$(echo "$DATAA" | sed -rn 's/.*Power_On_Hours.* ([0-9]*)$/\1/p')"
	WLC="$(echo "$DATAA" | sed -rn 's/.*Perc_Rated_Life_Used.* ([0-9]*)$/\1/p')"
	DATAH="$(smartctl -H $DEVICE 2>/dev/null | sed  -e '1,3d')"
	SMART="$(echo "$DATAH" | sed -rn 's/^SMART.*result: (.*)/\1/p' | sed "s/^PASSED$/$(lang de:"GUT" en:"PASSED")/g")"

	echo "<table width=100%>"
	echo "<tr>"
	[ -n "$FIRM" ] && FIRM=" ($FIRM)"
	echo "<tr><td>$NAME$FIRM</td><td>$SIZE</td></tr>"
	[ -n "$SMART" ] && echo "<tr><td>$(lang de:"Zustand" en:"Health")</td><td>$SMART</td></tr>"
	[ $WLC -gt 0 2>/dev/null ] && echo "<tr><td>$(lang de:"Restgesundheit" en:"Wear leveling")</td><td>$(( 100-$WLC ))&#037;</td></tr>"
	[ $TGC -gt 0 2>/dev/null ] && echo "<tr><td>$(lang de:"Temperatur" en:"Termperature")</td><td>$TGC &deg;C</td></tr>"
	[ $POH -gt 0 2>/dev/null ] && echo "<tr><td>$(lang de:"Laufzeit" en:"Power-on")</td><td>$(($POH/24)) $(lang de:"Tage" en:"days")</td></tr>"
	if [ $PCC -gt 0 2>/dev/null ]; then
		if [ $SSC -gt 0 2>/dev/null ]; then
			echo "<tr><td>$(lang de:"Einschalt- / Anlaufvorg&auml;nge" en:"Power cycles / spinups")</td><td>$PCC / $SSC</td></tr>"
		else
			echo "<tr><td>$(lang de:"Einschaltvorg&auml;nge" en:"Power cycles")</td><td>$PCC</td></tr>"
		fi
	else
		[ $SSC -gt 0 2>/dev/null ] && echo "<tr><td>$(lang de:"Anlaufvorg&auml;nge" en:"Spinups")</td><td>$SSC</td></tr>"
	fi
	echo "</tr>"
	echo "</table>"

	echo -n '<pre class="log full"><FONT SIZE=-1>'
	echo -e "\n$DATAI\n\n$DATAH\n\n$DATAA\n"
	echo '</FONT></pre>'
done

