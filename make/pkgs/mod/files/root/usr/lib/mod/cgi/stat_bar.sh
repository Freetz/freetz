show_perc() {
	if [ $# -ge 1 -a "$1" -gt 3 ]; then
		echo "$1%"
	fi
}

stat_bar() {
	local barstyle="br"
	if [ $# -gt 1 ]; then
		barstyle=$1; shift
	fi

	outhtml="<table class='bar $barstyle'><tr>"

	local i=1
	local sum=0
	for percent; do
		stat_bar_add_part $i $percent
		let i++
	done
	if let "sum < 100"; then
		stat_bar_add_part 0 $((100 - sum))
	fi
	if let "sum > 100"; then
		echo 'ERROR stat_bar: SUM > 100%'
	else
		echo "$outhtml</tr></table>"
	fi
}
stat_bar_add_part() {
	local n=$1 percent=$2
	if let "percent > 0"; then
		outhtml="$outhtml<td class='part$n' style='width: ${percent}%;'>$(show_perc $percent)</td>"
	fi
	let sum+=percent
}
