#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

get_env() {
	cat /proc/sys/urlader/environment | grep "^$1" | sed -e 's/'"$1"'	//'
}

stat_bar() {
	percent=$1; let bar="percent*4"; let grey="(100-percent)*4"
	echo '<p><img src="/images/green.png" width="'"$bar"'" height="10" border="0" alt=""><img src="/images/grey.png" width="'"$grey"'" height="10" border="0" alt=""></p>'
}

stat_button() {
	echo '<div class="btn"><form class="btn" action="/cgi-bin/exec.cgi" method="post"><input type="hidden" name="cmd" value="'"$1"'"><input type="submit" value="'"$2"'"></form></div>'
}

cgi_begin 'Status' 'status'
sec_begin 'Box'

cat << EOF
<p>
<form class="btn" action="/cgi-bin/exec.cgi" method="post">
$(lang de:"Firmware" en:"firmware"): $(get_env 'firmware_info')$(cat /etc/.subversion)<br>
$(lang de:"Branding" en:"branding"):
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
sec_begin '$(lang de:"Hauptspeicher" en:"Memory")'

total="$(cat /proc/meminfo | grep '^MemTotal:' | sed s/[^0-9]//g)"
free="$(cat /proc/meminfo | grep '^MemFree:' | sed s/[^0-9]//g)"
cached="$(cat /proc/meminfo | grep '^Cached:' | sed s/[^0-9]//g)"
let usedwc="total-cached-free"
let percent="100*usedwc/total"
echo "<p>Gesamt: $total KB<br>"
echo "Belegt: $usedwc KB (ohne Cache)</p>"
stat_bar $percent

sec_end
sec_begin 'Flash'

echo 'info' > /proc/tffs
percent="$(cat /proc/tffs | grep '^fill=')"
percent="${percent#fill=}"
echo "<p>$(lang de:"tffs ist zu ${percent}% belegt." en:"tffs fill: ${percent}%")</p>"
stat_bar $percent

sec_end

stat_button 'reboot' 'Reboot'
stat_button 'restart_dsld' 'Restart dsld'
stat_button 'cleanup' 'Cleanup tffs'
stat_button 'downgrade' 'Downgrade Mod'

cgi_end
