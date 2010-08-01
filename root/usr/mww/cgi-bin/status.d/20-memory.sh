has_swap() {
	free | awk '/Swap:/ { if ($2 == 0) exit 1; else exit 0 }'
}

read_meminfo() {
	eval "$(sed -rne "/^((Mem|Swap)(Total|Free)|(|Swap)Cached):/ s/^([^:]*):[[:space:]]*([0-9]*).*$/mem_\1=\2/p" /proc/meminfo)"
}
read_meminfo

sec_begin '$(lang de:"Physikalischer Speicher (RAM)" en:"Main memory (RAM)")'

total=$mem_MemTotal
free=$mem_MemFree
cached=$mem_Cached
let usedwc="total-cached-free"
let percent="100*usedwc/total"
let perc_buff="100*cached/total"
echo "<div>$usedwc kB (+ $cached kB $(lang de:"Cache" en:"cache")) $(lang de:"von" en:"of") $total kB $(lang de:"belegt" en:"used"), $free kB $(lang de:"frei" en:"free")</div>"
stat_bar br $percent $perc_buff

sec_end

sec_begin '$(lang de:"Flash-Speicher (TFFS) f&uuml;r Konfigurationsdaten" en:"Flash memory (TFFS) for configuration data")'

echo info > /proc/tffs
percent=$(grep '^fill=' /proc/tffs)
percent=${percent#fill=}
let tffs_size="0x$(awk '/tffs/ { print $2; exit }' /proc/mtd)/1024"
let tffs_used="tffs_size*percent/100"
let tffs_free="tffs_size - tffs_used"
echo "<div>$tffs_used kB $(lang de:"von" en:"of") $tffs_size kB $(lang de:"belegt" en:"used"), $tffs_free kB $(lang de:"frei" en:"free")</div>"
stat_bar $percent

sec_end

if has_swap; then
	sec_begin '$(lang de:"Swap-Speicher" en:"Swap") (RAM)'
	total=$mem_SwapTotal
	free=$mem_SwapFree
	cached=$mem_SwapCached
	let usedwc="total-cached-free"
	let percent="100*usedwc/total"
	let perc_buff="100*cached/total"
	echo "<div>$usedwc kB (+ $cached kB $(lang de:"Cache" en:"cache")) $(lang de:"von" en:"of") $total kB $(lang de:"belegt" en:"used"), $free kB $(lang de:"frei" en:"free")</div>"
	stat_bar br $percent $perc_buff
	sec_end
fi
