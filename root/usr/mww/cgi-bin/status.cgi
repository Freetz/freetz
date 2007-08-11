#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

get_env() {
	cat /proc/sys/dev/adam2/environment | grep "^$1" | sed -e 's/'"$1"'	//'
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
		all|cgi-bin|html)
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

free="$(cat /proc/meminfo | grep '^Mem:')"
echo "${free#Mem:}" | while read -r total used free shared buffers cached; do
	let usedwc="used-cached"
	let percent="100*usedwc/total"
	let total_kb="total/1024"
	let usedwc_kb="usedwc/1024"
	echo "<p>$(lang de:"Gesamt" en:"total"): $total_kb KB<br>"
	echo "$(lang de:"Belegt" en:"used"): $usedwc_kb KB ($(lang de:"ohne Cache" en:"without cache"))</p>"
	stat_bar $percent
done

sec_end
sec_begin 'Flash'

echo 'info' > /proc/tffs
percent="$(cat /proc/tffs | grep '^fill=')"
percent="${percent#fill=}"
echo "<p>$(lang de:"tffs ist zu ${percent}% belegt." en:"tffs fill: ${percent}%")</p>"
stat_bar $percent

sec_end

stat_button 'reboot' 'Reboot'
stat_button 'cleanup' 'Cleanup tffs'
stat_button 'downgrade' 'Downgrade Mod'

cgi_end
