get_env() {
	sed -n "s/^$1	//p" /proc/sys/urlader/environment
}

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
	echo '<form class="btn" action="/cgi-bin/exec.cgi/branding" method="post">'
	echo '$(lang de:"Branding" en:"Branding"):'
	echo '<select name="branding" size="1">'
	branding=$(get_env firmware_version)
	for i in $BRANDS; do
		echo "<option value='$i'$([ "$i" = "$branding" ] && echo ' selected')>$i</option>"
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
