#!/bin/sh

PATH=/mod/bin:/mod/usr/bin:/mod/sbin:/mod/usr/sbin:/bin:/usr/bin:/sbin:/usr/sbin

# include environment variables
[ -r /var/env.cache ] && . /var/env.cache

notdefined='$(lang de:"unbekannt" en:"unknown")'
divstyle="style='margin-top:6px;'"

getNetworkInfo() {
ifconfig | sed -ne '/^[^ ^\t][a-z0-9:]*[ \t]*Link encap:/N/inet addr:/N/inet addr/s/[ \t]*\n[ \t]*/ /gp'\
| sed -e 's/ UP .*//;s/[ \t]*Link encap:\([^ ]*\).*inet addr:\([0-9.]*\)/ \1 \2/;s/[ \t]*Mask:[0-9.]*//;s/[ \t]*Bcast:[0-9.]*//;s/[ \t]*Scope:.*//;s/[ \t]*inet6 addr: / /;s/[ \t]*P-t-P:[0-9.]*//'\
| while read interface itype ipv4 ipv6
	do
		hostname="$(sed -ne "/^${ipv4}[ \t][ \t]*/s/[0-9.]*[ \t]*//p" /etc/hosts | sed -e 's/[ \t]/; /g')"
		echo "$interface $itype $ipv4 $hostname"
	done
}

if [ -r /var/env ]; then
	while read -r key value; do
		case $key in
			bootloaderVersion) loaderversion=$value ;;
			my_ipaddress)	ip_init_address=$value ;;
			maca)		mac_lan=$value ;;
			macdsl)		mac_dsl=$value ;;
			macwlan)	mac_wlan=$value ;;
		esac
	done < /var/env
else
	loaderversion=$notdefined
	ip_init_address=$notdefined
	mac_lan=$notdefined
	mac_dsl=$notdefined
	mac_wlan=$notdefined
fi
if [ -r /proc/cpuinfo ]; then
	cpu_family=$(sed -ne '/system type/ s/.*: //p' /proc/cpuinfo)
	cpu_model=$(sed -ne '/cpu model/ s/.*: //p' /proc/cpuinfo)
else
	cpu_family=""
	cpu_model=""
fi
if [ -r /etc/version ]; then
	avm_date=$(sed -ne 's/^export FIRMWARE_DATE\="\(.*\)"/\1/p' /etc/version)
else
	avm_date=$notdefined
fi
if [ -r /etc/.revision ]; then
	avm_revision=$(cat /etc/.revision)
else
	avm_revision=$notdefined
fi
if [ -r /proc/sys/urlader/environment ]; then
	flash_size=$(($(sed -ne "s/^flashsize.\([0-9x].*\)/\1/p" /proc/sys/urlader/environment) / 0x100000))
else
	flash_size=$CONFIG_ROMSIZE
fi
if [ -x $(which run_clock) ]; then
	run_clock=$(run_clock | sed 's/.*: //')
fi

sec_begin '$(lang de:"Hardware-Informationen" en:"Information about hardware")'
 echo '<div '$divstyle'><b>$(lang de:"Boxname" en:"Box name"):</b> '$CONFIG_PRODUKT_NAME'&nbsp;&nbsp;&nbsp;<b>ANNEX:</b> '$CONFIG_ANNEX'</div>'
 echo -n "<div $divstyle><b>HWRevision:</b> $HWRevision.$(($HWRevision_ATA)).$((HWRevision_BitFileCount)).$(($HWRevision_Reserved1))&nbsp;&nbsp;&nbsp;"
 echo "<b>Flash(ROM):</b> $flash_size MB&nbsp;&nbsp;&nbsp;<b>RAM:</b> $CONFIG_RAMSIZE MB</div>"
 echo "<div $divstyle>"
 if [ ! -z "$cpu_family" ]; then
	echo '<b>CPU$(lang de:"-Familie" en:" family"):</b> '$cpu_family'&nbsp;&nbsp;&nbsp;'
 fi
 if [ ! -z "$cpu_model" ]; then
	echo '<b>CPU$(lang de:"-Modell" en:" model"):</b> '$cpu_model
 fi
 echo "</div>"
 echo '<div '$divstyle'><b>$(lang de:"Taktfrequenzen" en:"Clock frequencies"):</b><br>'
 sed 's/ [ ]*/ /g;s/^Clocks: //;s/^[A-Z0-9 ]*Clock: //;s/\([A-Za-z0-9]*:\)[ ]*\([0-9,.]*\)[ ]*\([a-zA-Z]*\) */<b>\1<\/b>\&nbsp\;\2\&nbsp\;\3\&nbsp\;\&nbsp\; /g;' /proc/clocks 2>/dev/null
 echo '</div>' 
 echo '<div '$divstyle'><b>$(lang de:"Betriebsstundenz&auml;hler" en:"Operating hours counter"):</b> '$run_clock'</div>'
sec_end

sec_begin '$(lang de:"Netzwerk" en:"Network")'
 host_name=$(hostname)
 ext_name="$(sed 's/.*[ \t]//g' /var/tmp/ddnsstat.txt 2>/dev/null)"
 act_ip=$(hostname -i)
 pubip="$(/usr/bin/get_ip -d)"
 echo '<table width="100%"><tr><td><b>$(lang de:"Netze" en:"Networks"):</b></td>'
 echo '<td><b><small>IP-$(lang de:"Adresse" en:"Address")</small></b></td>'
 echo '<td><b><small>Hostname</small></b></td></tr>'
 if [ -n "$pubip" ]
 then
	echo '<tr><td><b><small>$(lang de:"&Ouml;ffentlich" en:"Public")</small></b></td>'
	echo "<td>$pubip</td>"
	[ -n "$ext_name" ] && ping_ip=$(ping -c 1 -W 1 "$ext_name" 2>/dev/null | sed -n 's/^PING .*(\(.*\)).*/\1/p')
	[ "$pubip" = "$ping_ip" ] && echo "<td>$ext_name</td>"
	echo '</tr>'
 fi
 echo '<tr><td><b><small>$(lang de:"Intern" en:"Internal")</small></b></td>'
 echo "<td>$act_ip</td><td>$host_name</td></tr>"
 echo '<tr><td><b><small>$(lang de:"Urloader" en:"Boot loader")</small></b></td>'
 echo "<td>$ip_init_address</td></tr></table>"

 echo '<table width="100%"><tr><td><b>$(lang de:"Schnittstellen" en:"Interfaces"):&nbsp;&nbsp;</b></td><td><b><small>$(lang de:"Protokoll" en:"Protocol")</small></b></td>'
 echo '<td><b><small>$(lang de:"IP-Adresse" en:"IP address")</small></b></td><td><b><small>$(lang de:"Namen" en:"Names")</small></b></td></tr>'
 getNetworkInfo | while read i p a n; do
	[ -z "$(echo "$a" | grep -E '169.|127.')" ] && echo "<tr><td>$i</td><td>$p</td><td>$a</td><td><small>$n</small></td></tr>"
 done
 echo '</table>'

 echo '<div '$divstyle'><b>MAC$(lang de:"-Adressen" en:" address"):</b><br>'
 echo '<b>DSL:</b> <small>'$mac_dsl'</small>&nbsp;&nbsp;&nbsp;<b>LAN:</b> <small>'$mac_lan'</small>&nbsp;&nbsp;&nbsp;<b>WLAN:</b> <small>'$mac_wlan'</small></div>'
sec_end

avsar_ver=/proc/avalanche/avsar_ver
if [ -r "$avsar_ver" ]; then
	sec_begin '$(lang de:"DSL-Treiber und Hardware" en:"DSL drivers and hardware")'
		echo "<pre class='plain'>$(cat "$avsar_ver")</pre>"
	sec_end
fi

sec_begin '$(lang de:"Firmware-Informationen" en:"Information about firmware")'
 echo -n '<div '$divstyle'><b>Firmware$(lang de:"" en:" ")version:</b> '$CONFIG_VERSION_MAJOR'.'$CONFIG_VERSION'&nbsp;&nbsp;'
 echo -n '<b>AVM-Revision:</b> '$avm_revision'&nbsp;&nbsp;&nbsp;'
 echo -n '<b>$(lang de:"Sprache" en:"Language"):</b> '$Language'</div>'
 echo '<div '$divstyle'><b>$(lang de:"Erstellungsdatum" en:"Compilation date") (AVM):</b> '$avm_date'</div>'
 echo '<div '$divstyle'><b>$(lang de:"Bootloaderversion" en:"Version of bootloader"):</b> '$loaderversion'</div>'
sec_end

if [ -r /var/env.cache ]; then
	sec_begin '$(lang de:"Umgebungsvariablen" en:"Environment variables")'
		echo -n '<div class="textwrapper"><textarea style="margin-top:6px;" name="content" rows="5" cols="10" wrap="off" readonly>'
		sed -e "s/^export //g" /var/env.cache | html
		echo -n '</textarea></div>'
	sec_end
fi
