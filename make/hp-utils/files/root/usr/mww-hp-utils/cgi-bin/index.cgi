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
supp_sel=$sel
maint_sel=''
maint_clean_sel=''
maint_align_sel=''
cat << EOF
<div class="menu">
<div$supp_sel><a href="/cgi-bin/index.cgi">$(lang de:"Verbrauchsmaterialien" en:"Supplies")</a></div>
<div$maint_sel><a href="/cgi-bin/maint.cgi">$(lang de:"Wartung" en:"Maintenance")</a></div>
<div$maint_clean_sel class="su"><a href="/cgi-bin/maint.cgi?action=clean">$(lang de:"Druckkopfreinigung" en:"Print Cartridge Cleaning")</a></div>
<div$maint_align_sel class="su"><a href="/cgi-bin/maint.cgi?action=align">$(lang de:"Druckkopfausrichtung" en:"Print Cartridge Alignment")</a></div>
</div>
EOF

sec_begin "$(lang de:"Verbrauchsmaterialien" en:"Supplies")"
if [ -z "$HP_UTILS_URI" ]; then
	echo "<p>$(lang de:"Drucker nicht konfiguriert." en:"Printer not configured.")</p>"
else
	_IFS=$IFS
	IFS="
	"
	levels=`hp-levels --device "$HP_UTILS_URI" --web-interface 2>/dev/null`
	if [ $? -ne 0 ]; then
		echo "<p>$(lang de:"Drucker nicht gefunden." en:"Printer not found.")</p>"
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
			echo "</tr>"
		done
		echo "</table>"
	fi
	IFS=$_IFS
fi

sec_end

cgi_end
