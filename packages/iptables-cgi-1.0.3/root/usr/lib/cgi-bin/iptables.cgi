#!/bin/sh

typeset -i i

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/var/mod/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk='';
if [ "$IPTABLES_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin 'Activation'
cat << EOF
<div style="float: right;"><font size="1">Version 1.0.3</font></div>
<p>
<input id="e1" type="radio" name="enabled" value="yes" $auto_chk><label for="e1"> Active</label>
<input id="e2" type="radio" name="enabled" value="no" $man_chk><label for="e2"> Inactive</label>
</p>
EOF
sec_end

sec_begin 'iptables add/remove rule'
cat << EOF
<p>
<input type="hidden" name="gui" value="*gui*">
<input type="radio" name="rule" value="-A"> Add
<input type="radio" name="rule" value="-D"> Delete
<input type="radio" name="rule" value="-I"> Insert
<br>
<table border="0">
<tr><td>Chain</td><td colspan="2"><select name="chain">
EOF

for CHAIN in $(iptables --list |grep "Chain"|sed -e "s/Chain //g"|sed -e "s/ .*//g"); do
	echo '<option title="'$CHAIN'" value="'$CHAIN'">'$CHAIN'</option>' 
done

cat << EOF
</select></td/</tr>
<tr><td>Position (ID)</td><td colspan="2"><input type="text" name="position" size="4" maxlength="6"> (only for Delete/Insert!)</tr>
<tr><td>Source Address</td><td><input type="text" name="source" size="20" maxlength="18" value="$(httpd -e "$IPTABLES_SOURCE")"></td><td>Port <input type="text" name="sport" size="5" maxlength="6" value="ANY"></td></tr>
<tr><td>Destination Address</td><td><input type="text" name="destination" size="20" maxlength="18" value="$(httpd -e "$IPTABLES_DESTINATION")"></td>
<td>Port <select name="dport">
<option title="dport" value="ANY">ANY</option>
EOF

while read DPORT; do
	DPORT="$(echo $DPORT|sed -e "s/:.*//g")"
	echo '<option title="dport" value="'$DPORT'">'$DPORT'</option>'
done < /tmp/flash/iptables_services

cat << EOF
</select></td></tr>
<tr><td>Protokoll</td><td colspan="2"><select name="protokoll">
<option title="tcp" value="tcp">tcp</option>
<option title="udp" value="udp">udp</option>
<option title="icmp" value="icmp">icmp</option>
</select>
<tr><td>Interface</td><td colspan="2"><select name="interface">
<option title="tcp" value="tcp">ANY</option>
EOF

for INTERFACE in $(ifconfig |grep ^[a-z]|cut -f1 -d ' '); do
	echo '<option title="'$INTERFACE'" value="'$INTERFACE'">'$INTERFACE'</option>'
done

cat << EOF  

</select>
</table>
<hr>
Action <select name="action">
<option title="ACCEPT" value="ACCEPT">ACCEPT</option>
<option title="DROP" value="DROP">DROP</option>
<option title="MASQUERADE" value="MASQUERADE">MASQUERADE</option>
</select>
</p>

EOF
sec_end


sec_begin 'iptables rules'

iptables -vL --line-numbers >/var/tmp/test
sed -e "s/\*/x/g" /var/tmp/test > /var/tmp/iptables_tmp
rm /var/tmp/test
i=0

while read IPTABLES_LINE; do
	if [[ $(echo ${IPTABLES_LINE} |grep -c "Chain") = 1 ]]; then
		# not first dataset, so close table
		if (( i > 0 )); then
			echo "</table>"
		fi
		echo "<br>"
		echo "<table width='100%' class='center' border='1' cellpadding='4' cellspacing='0'>"
		echo "<tr><td align='left' colspan='8'>${IPTABLES_LINE}</td>"
		echo "</tr><tr>"
		echo "<th bgcolor="#bae3ff">ID</th>"
		echo "<th bgcolor="#bae3ff">Source</th>"
		echo "<th bgcolor="#bae3ff">Destination</th>"
		echo "<th bgcolor="#bae3ff">Protokoll</th>"
		echo "<th bgcolor="#bae3ff">Service</th>"
		echo "<th bgcolor="#bae3ff">Service</th>"
		echo "<th bgcolor="#bae3ff">Action</th>"
		echo "<th bgcolor="#bae3ff">in</th>"
		echo "</tr>"
		i=i+1
	else
		echo ${IPTABLES_LINE} | grep "^[1-9]" > /dev/null
		if [ $? = 0 ]; then 
			echo "<tr>"
			echo "<td>$(echo ${IPTABLES_LINE} | awk '{print $1}')</td>"
			echo "<td>$(echo ${IPTABLES_LINE} | awk '{print $9}')</td>"
			echo "<td>$(echo ${IPTABLES_LINE} | awk '{print $10}')</td>"
			echo "<td>$(echo ${IPTABLES_LINE} | awk '{print $5}')</td>"

			if [ ! $(echo ${IPTABLES_LINE} | awk '{print $12}') ]; then
				 echo "<td>ANY</td>"
			else
				PORT="$(echo ${IPTABLES_LINE} | awk '{print $12}' | sed -e "s/.*://g")"
				SERVICE="$(cat /tmp/flash/iptables_services | grep :$PORT$ | sed -e "s/:.*//g")"
				echo "<td>$(echo ${IPTABLES_LINE} | awk '{print $12}' | sed -e "s/:.*//g"):$SERVICE</td>"
			fi

			if [ ! $(echo ${IPTABLES_LINE} | awk '{print $13}') ]; then
				echo "<td>ANY</td>"
			else
				PORT="$(echo ${IPTABLES_LINE} | awk '{print $13}' | sed -e "s/.*://g")"
				SERVICE="$(cat /tmp/flash/iptables_services | grep :$PORT$ | sed -e "s/:.*//g")"
				echo "<td>$(echo ${IPTABLES_LINE} | awk '{print $13}' | sed -e "s/:.*//g"):$SERVICE</td>"
			fi

			IMAGE="$(echo ${IPTABLES_LINE} | awk '{print $4}')"
			echo "<td align="center"><img src='../images/"$IMAGE".gif' title='"$IMAGE"'></td>"
			echo "<td>$(echo ${IPTABLES_LINE} | awk '{print $7}')</td>"
			echo "</tr>"
		fi
	fi
done < /var/tmp/iptables_tmp
echo "</table>"
rm /var/tmp/iptables_tmp

sec_end
