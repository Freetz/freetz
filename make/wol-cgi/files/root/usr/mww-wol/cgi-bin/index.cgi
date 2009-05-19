#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin

cgi_width=560
. /usr/lib/libmodcgi.sh

cgi_begin 'Wake on LAN'

cat << EOF
<p>
$(lang de:"Bekannte Hosts" en:"Known hosts"):
<select onChange="var s = this.options[this.options.selectedIndex].value; document.wake.mac.value = s.substr(0,s.search(/\*/)); document.wake.interf.value = s.substr(s.search(/\*/)+1); return false;">
<option value="*" selected>$(lang de:"(w&auml;hlen)" en:"(choose)")</option>
EOF

if [ -r /tmp/flash/mod/hosts ]; then
	egrep -v '^(#|[[:space:]]*$)' /tmp/flash/mod/hosts |
		while read -r ip mac interface host desc; do
			if [ dhcp-host = "$mac" ]; then
				if [ -n "$host" -a -r /var/tmp/multid.leases ]; then
					mac=`sed "/${host}/!d;s/^lease //;s/ .*//" /var/tmp/multid.leases`
				else
					continue
				fi
			fi
			if [ -n "$mac" -a "$mac" != "*" ]; then
				if [ -n "$interface" -a "$interface" != "*" ]; then
					value="$mac*$interface"
				else
					value="$mac*"
				fi

				echo -n '<option value="'"$value"'">'
				if [ -n "$desc" ]; then
					[ '*' != "$host" ] && echo -n "$host "
					echo -n "$desc"
				elif [ -n "$host" -a "$host" != "*" ]; then 
					echo -n "$host"
				else
					echo -n "$mac"
				fi
				echo '</option>'
			fi
		done
fi

cat << EOF
</select>
</p>
<p>$(lang de:"MAC und Netzwerk-Schnittstelle f&uuml;r Etherwake angeben oder einen der bekannten Hosts w&auml;hlen." en:"Fill in a MAC address and a network interface for etherwake or select a known host from the drop down list above.")</p>
<form style="padding-top: 10px; padding-bottom: 10px;" name="wake" action="/cgi-bin/wake.cgi" method="post">
<table border="0" cellspacing="1" cellpadding="0">
<tr>
<td width="230">MAC: <input type="text" name="mac" size="17" maxlength="17" value=""></td>
<td width="210">Interface: <select name="interf">
EOF
echo '<option title="tcp" value="tcp">'$interface'</option>'

for INTERFACE in $(ifconfig |grep ^[a-z]|cut -f1 -d ' '); do
	echo '<option title="'$INTERFACE'" value="'$INTERFACE'">'$INTERFACE'</option>'
done

cat << EOF

</select></td>
<td width="100"><input type="submit" value="WakeUp"></td>
</tr>
</table>
</form>
EOF

cgi_end
