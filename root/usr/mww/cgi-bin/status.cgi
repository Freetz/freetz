#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

get_env() {
	cat /proc/sys/urlader/environment | grep "^$1" | sed -e 's/'"$1"'	//'
}

stat_bar() {
	percent=$1; let bar="percent*4"; let grey="(100-percent)*4"
	echo '<p><img src="/images/green.png" width="'"$bar"'" height="10" border="0" alt=""><img src="/images/grey.png" width="'"$grey"'" height="10" border="0" alt=""> &nbsp;&nbsp;'$percent' %</p>'
}

stat_button() {
	echo '<div class="btn"><form class="btn" action="/cgi-bin/exec.cgi" method="post"><input type="hidden" name="cmd" value="'"$1"'"><input type="submit" value="'"$2"'" style="width: 174px"></form></div>'
}

cgi_begin '$(lang de:"Status" en:"Status")' 'status'
sec_begin '$(lang de:"Box" en:"Box")'

cat << EOF
<p>
<form class="btn" action="/cgi-bin/exec.cgi" method="post">
$(lang de:"Firmware" en:"Firmware"): $(get_env 'firmware_info')$(cat /etc/.subversion)<br>
$(lang de:"Branding" en:"Branding"):
<input type="hidden" name="cmd" value="branding">
<select name="branding" size="1">
EOF

branding="$(get_env 'firmware_version')"
for i in $(ls /usr/www/); do
	case "$i" in
		all|cgi-bin|html|kids)
			;;
		*)
			echo "<option value=\"$i\"$([ "$i" = "$branding" ] && echo ' selected')>$i</option>"
			;;
	esac
done

cat << EOF
</select>
<input type="submit" value="Ok">
</form>
</p>
EOF

sec_end
sec_begin '$(lang de:"Hauptspeicher (RAM)" en:"Main memory (RAM)")'

total="$(cat /proc/meminfo | grep '^MemTotal:' | sed s/[^0-9]//g)"
free="$(cat /proc/meminfo | grep '^MemFree:' | sed s/[^0-9]//g)"
cached="$(cat /proc/meminfo | grep '^Cached:' | sed s/[^0-9]//g)"
let usedwc="total-cached-free"
let percent="100*usedwc/total"
echo "<p>$usedwc $(lang de:"von" en:"of") $total KB $(lang de:"belegt (ohne Cache)" en:"used (without cache)")</p>"
stat_bar $percent

sec_end
sec_begin '$(lang de:"Flash-Speicher (TFFS) für Konfigurationsdaten" en:"Flash memory (TFFS) for configuration data")'

echo 'info' > /proc/tffs
percent="$(cat /proc/tffs | grep '^fill=')"
percent="${percent#fill=}"
let tffs_size="$(printf "%d" "0x$(cat /proc/mtd | grep tffs | head -n1 | awk '{print $2}')")/1024"
let tffs_used="tffs_size*percent/100"
echo "<p>$tffs_used $(lang de:"von" en:"of") $tffs_size KB $(lang de:"belegt" en:"used")</p>"
stat_bar $percent

sec_end

stat_button 'restart_dsld' '$(lang de:"DSL-Reconnect" en:"Reconnect DSL")'
stat_button 'cleanup' '$(lang de:"TFFS aufräumen" en:"Clean up TFFS")'
stat_button 'fw_attrib' '$(lang de:"Attribute bereinigen" en:"Clean up attributes")'
stat_button 'downgrade' '$(lang de:"Downgrade-Mod" en:"Downgrade mod")'
stat_button 'reboot' '$(lang de:"Reboot" en:"Reboot")'

cgi_end
