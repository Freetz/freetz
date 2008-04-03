
stat_bar() {
	let multip="($_cgi_width-230-50)/100";
	percent=$1; let bar="percent*multip"; let grey="(100-percent)*multip"
	echo '<p><img src="/images/green.png" width="'"$bar"'" height="10" border="0" alt=""><img src="/images/grey.png" width="'"$grey"'" height="10" border="0" alt=""> &nbsp;&nbsp;'$percent' %</p>'
}

sec_begin '$(lang de:"Eingeh&auml;ngte Partitionen" en:"Mounted partitions")'
MPOINTS=$(mount|grep -E "^/dev/sd|^/dev/mapper/|^.* on .* type cifs"|cut -d" " -f3)
if [ "$MPOINTS" ]; then
	for path in $MPOINTS; do
		dfrow=$(df -h|grep " $path$")
		total="$(  echo $dfrow | awk '{print $2}' | sed 's/k/ K/;s/M/ M/;s/G/ G/')"
		used="$(   echo $dfrow | awk '{print $3}' | sed 's/k/ K/;s/M/ M/;s/G/ G/')"
		percent="$(echo $dfrow | awk '{print $5}' | sed 's/[^0-9]//')"
		device="$(echo $dfrow | awk '{print $1}')"
		echo "<p><b>$path</b> ($device):<br>"$used"B $(lang de:"von" en:"of") "$total"B $(lang de:"belegt" en:"used")</p>"
		stat_bar $percent
	done
else
	echo "<br>$(lang de:"keine gefunden" en:"none found")<br>"
fi
sec_end

