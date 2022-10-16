#!/bin/sh

. /usr/lib/libmodcgi.sh

if [ "$SISPMCTL_SKIN" = "web2" ]
then
	[ -d /usr/share/sispmctl-web2 ] || SISPMCTL_SKIN="web1"
fi

skin_web1=''; skin_web2=''
[ "$SISPMCTL_SKIN" = "web1" ] && skin_web1=' selected'
[ "$SISPMCTL_SKIN" = "web2" ] && skin_web2=' selected'

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SISPMCTL_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Integrierter WEB-Server" en:"Integrated WEB Server")"

if [ -d /usr/share/sispmctl-web2 ]
then
cat << EOF
<p>Skin:
<select name="skin" id="skin">
<option title="Standard" value="web1"$skin_web1>Standard</option>
EOF
if [ -d /usr/share/sispmctl-web2 ]
then
cat << EOF
<option title="Smartphone" value="web2"$skin_web2>Smartphone</option>
EOF
fi
cat << EOF
</select>
EOF
fi
cat << EOF
&nbsp;&nbsp;&nbsp;$(lang de:"Default-Port" en:"Default port"): <input type="text" name="port" size="5" maxlength="5" value="$(html "$SISPMCTL_PORT")"></p>
EOF
sec_end

sispmss="$(sispmctl -s)"
IDs="$(echo "$sispmss" | sed -n -e '/serial number/s/serial number\:[[:space:]]*//p')"
TYPEs="$(echo "$sispmss" | sed -n -e '/device type/s/device type\:[[:space:]]*//p')"
if [ -n "$IDs" ]
then
	NUMB_DEV=$(echo "$IDs" | wc -l)
	sec_begin "$(lang de:"Erkannte Steckdosenleisten" en:"Detected multiple socket outlets")"

	echo "<table><tr><td>"
	echo "<font size="-2"><b>$(lang de:"Seriennummer" en:"Serial No")&nbsp;&nbsp;</b></font></td>"
	echo "<td><font size="-2"><b>$(lang de:"Typ" en:"Type")&nbsp;&nbsp;</b></font></td>"
	echo '<td><font size="-2"><b>Name&nbsp;&nbsp;</b></font></td>'
	echo "<td><font size="-2"><b>$(lang de:"Status" en:"State")&nbsp;&nbsp;</b></font></td></tr>"
	ii=1
	while [ $ii -le $NUMB_DEV ]
	do
		get_onoff="$(sispmctl -q -d$(($ii - 1)) -g all)"
		get_ps="$(sispmctl -q -d$(($ii - 1)) -m all)"
		curr_id="$(echo "$IDs" | sed -n "${ii}p")"
		echo "<tr><td>"
		echo "$curr_id"
		echo "&nbsp;&nbsp;</td>"
		echo "<td>"
		echo "$TYPEs" | sed -n "${ii}p"
		echo "&nbsp;&nbsp;</td><td>"
		jj=1
		ll=0
		while [ $jj -le $((SISPMCTL_NUMOFDEV)) ]
		do
			eval ID_GLOBAL=\$SISPMCTL_D${jj}_ID
			eval NAME_GLOBAL=\$SISPMCTL_D${jj}_NAME
			if [ "$curr_id" = "$ID_GLOBAL" ]
			then
				echo "$NAME_GLOBAL"
				[ $ll -eq 0 ] && ll=$jj
			fi
			jj=$(($jj + 1))
		done
		echo "&nbsp;&nbsp;</td>"
		kk=1
		while [ $kk -le 4 ]
		do
			eval NAME_O_curr=\$SISPMCTL_D${ll}_O${kk}
			[ -z "$NAME_O_curr" ] && NAME_O_curr="Socket ${kk}"
			curr_onoff="$(echo "$get_onoff" | sed -n "${kk}p")"
			curr_ps="$(echo "$get_ps" | sed -n "${kk}p")"
			if [ "$curr_onoff" = "on" -a "$curr_ps" = "on" ]
			then
				echo "<td style='background-color: #00FF00;'>"
			else
				if [ "$curr_onoff" = "on" -a "$curr_ps" = "off" ]
				then
					echo "<td style='background-color: #FFFF00;'>"
				else
					echo "<td style='background-color: #FF0000;'>"
				fi
			fi
			echo "<font size="-2"><b>$NAME_O_curr&nbsp;&nbsp;</b></font></td>"
			kk=$(($kk + 1))
		done
		echo "</tr>"
		ii=$(($ii + 1))
	done
	echo "</table>"

	sec_end
else
	NUMB_DEV=0
fi

sec_begin "$(lang de:"Zuordnung und Benennung der Steckdosen" en:"Allocation and naming")"

cat << EOF
<p>$(lang de:"Anzahl der verwalteten Steckdosenleisten" en:"Number of administrated devices"):
<select name="numofdev" id="numofdev">
EOF
ii=1
while [ $ii -le 9 ]
do
	[ "$ii" = "$SISPMCTL_NUMOFDEV" ] && number_selected=' selected' || number_selected=''
	cat << EOF
<option title="$ii" value="$ii"$number_selected>$ii</option>
EOF
	ii=$(($ii + 1))
done
echo "</select></p>"

echo '<table><tr><td>'
echo "<font size="-2"><b>$(lang de:"Seriennummer" en:"Serial No")&nbsp;&nbsp;&nbsp;</b></font></td>"
echo "<td><font size="-2"><b>$(lang de:"Benennung" en:"Naming")&nbsp;&nbsp;&nbsp;</b></font></td>"
echo "<td><font size="-2"><b>$(lang de:"Steckdose" en:"Socket") 1&nbsp;&nbsp;&nbsp;</b></font></td>"
echo "<td><font size="-2"><b>$(lang de:"Steckdose" en:"Socket") 2&nbsp;&nbsp;&nbsp;</b></font></td>"
echo "<td><font size="-2"><b>$(lang de:"Steckdose" en:"Socket") 3&nbsp;&nbsp;&nbsp;</b></font></td>"
echo "<td><font size="-2"><b>$(lang de:"Steckdose" en:"Socket") 4&nbsp;&nbsp;&nbsp;</b></font></td>"
echo '<td><font size="-2"><b>Port&nbsp;&nbsp;&nbsp;</b></font></td></tr>'
ii=1
while [ $ii -le $SISPMCTL_NUMOFDEV ]
do
	eval ID_GLOBAL=\$SISPMCTL_D${ii}_ID
	eval NAME_GLOBAL=\$SISPMCTL_D${ii}_NAME
	eval NAME_O1=\$SISPMCTL_D${ii}_O1
	eval NAME_O2=\$SISPMCTL_D${ii}_O2
	eval NAME_O3=\$SISPMCTL_D${ii}_O3
	eval NAME_O4=\$SISPMCTL_D${ii}_O4
	eval PORT_NUMBER=\$SISPMCTL_D${ii}_PORT
	cat << EOF
	<tr>
<td><input type="text" name="d${ii}_id" size="14" maxlength="14" value="$(html "$ID_GLOBAL")"></td>
<td><input type="text" name="d${ii}_name" size="8" maxlength="8" value="$(html "$NAME_GLOBAL")"></td>
<td><input type="text" name="d${ii}_o1" size="8" maxlength="8" value="$(html "$NAME_O1")"></td>
<td><input type="text" name="d${ii}_o2" size="8" maxlength="8" value="$(html "$NAME_O2")"></td>
<td><input type="text" name="d${ii}_o3" size="8" maxlength="8" value="$(html "$NAME_O3")"></td>
<td><input type="text" name="d${ii}_o4" size="8" maxlength="8" value="$(html "$NAME_O4")"></td>
<td><input type="text" name="d${ii}_port" size="5" maxlength="5" value="$(html "$PORT_NUMBER")"></td>
</tr>
EOF
	ii=$(($ii + 1))
done
echo "</table>"

sec_end
