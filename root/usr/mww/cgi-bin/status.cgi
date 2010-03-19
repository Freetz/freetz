#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

get_env() {
	sed -n "s/^$1	//p" /proc/sys/urlader/environment
}

read_meminfo() {
	eval "$(sed -rne "/^((Mem|Swap)(Total|Free)|(|Swap)Cached):/ s/^([^:]*):[[:space:]]*([0-9]*).*$/mem_\1=\2/p" /proc/meminfo)"
}
read_meminfo

btn_count=0
stat_button() {
	let _btn_width="($_cgi_width-230+16)/3"
	btn_count=$((btn_count + 1))
	echo '<div class="btn"><form class="btn" action="/cgi-bin/exec.cgi" method="post"><input type="hidden" name="cmd" value="'"$1"'"><input type="submit" value="'"$2"'" style="width: '$_btn_width'px"></form></div>'
	[ $btn_count -eq 3 ] && ( btn_count=0; echo '<br style="clear:left">' )
}

has_swap() {
        free | awk '/Swap:/ { if ($2 == 0) exit 1; else exit 0 }'
}

default_password_set() {
	[ "$MOD_HTTPD_PASSWD" == '$1$$zO6d3zi9DefdWLMB.OHaO.' ]
}

cgi_begin '$(lang de:"Status" en:"Status")' 'status'

if default_password_set; then
	echo '<div style="color: #800000;"><p>$(lang
		de:"Standard-Passwort gesetzt. Bitte
		<a href=\"/cgi-bin/passwd.cgi\"><u>hier</u></a> ändern."
		en:"Default password set. Please change
		<a href=\"/cgi-bin/passwd.cgi\"><u>here</u></a>."
	)</p>'
fi

sec_begin '$(lang de:"Box" en:"Box")'

cat << EOF
<p>
$(lang de:"Firmware" en:"Firmware"): $(get_env firmware_info)$(cat /etc/.freetz-version)
</p>
<table width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td>
EOF

brands_cnt=0
for i in $(ls /usr/www/); do
	case $i in
		all|cgi-bin|html|kids)
			;;
		*)
			BRANDS="$BRANDS $i" 
			let brands_cnt++
			;; 
	esac
done

if [ $brands_cnt -gt 1 ]; then 
	echo '<form class="btn" action="/cgi-bin/exec.cgi" method="post">'
	echo '$(lang de:"Branding" en:"Branding"):'
	echo '<input type="hidden" name="cmd" value="branding">'
	echo '<select name="branding" size="1">' 
	branding=$(get_env firmware_version) 
	for i in $BRANDS; do 
		echo "<option value=\"$i\"$([ "$i" = "$branding" ] && echo ' selected')>$i</option>" 
	done 
	echo '</select>' 
	echo '<input type="submit" value="Ok">' 
	echo '</form>' 
else
	branding=$(get_env firmware_version) 
	BRANDS=${BRANDS# }
	echo "$(lang de:"Branding" en:"Branding"):"
	echo "$branding" 
	if [ "$branding" != "$BRANDS" ]; then 
		echo "($(lang de:"nicht installiert" en:"not installed"))" 
	fi 
fi

cat << EOF

</td>
<td align="right">$(lang de:"Uptime" en:"Uptime"): $(uptime | sed -r 's/.* up (.*), load .*/\1/')</td></tr>
</table>
EOF

sec_end
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
sec_begin '$(lang de:"Flash-Speicher (TFFS) für Konfigurationsdaten" en:"Flash memory (TFFS) for configuration data")'

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

[ "$MOD_MOUNTED_MAIN" = yes ] && . /usr/lib/cgi-bin/mod/mounted.cgi

stat_button restart_dsld '$(lang de:"DSL-Reconnect" en:"Reconnect DSL")'
stat_button cleanup '$(lang de:"TFFS aufräumen" en:"Clean up TFFS")'
stat_button fw_attrib '$(lang de:"Attribute bereinigen" en:"Clean up attributes")'
stat_button downgrade '$(lang de:"Downgrade-Mod" en:"Downgrade mod")'
stat_button firmware_update '$(lang de:"Firmware-Update" en:"Update firmware")'
stat_button reboot '$(lang de:"Reboot" en:"Reboot")'

cgi_end
