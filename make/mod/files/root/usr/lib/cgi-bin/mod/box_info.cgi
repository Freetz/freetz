#!/bin/sh



# include environment variables
[ -r /var/env.cache ] && . /var/env.cache

notdefined='$(lang de:"unbekannt" en:"unknown")'
divstyle="style='margin-top:6px;'"

getNetworkInfo() {
	ifconfig | sed -ne '
		/^[a-z0-9:]*[ \t]*Link encap:/N
		/inet addr:/N
		/inet addr/s/[ \t]*\n[ \t]*/ /gp
	' | sed -e '
		s/ UP .*//
		s/[ \t]*Link encap:\([^ ]*\).*inet addr:\([0-9.]*\)/ \1 \2/
		s/[ \t]*Mask:[0-9.]*//
		s/[ \t]*Bcast:[0-9.]*//
		s/[ \t]*Scope:.*//
		s/[ \t]*inet6 addr: / /
		s/[ \t]*P-t-P:[0-9.]*//
	' | while read interface itype ipv4 ipv6; do
		hostname=$(sed -ne "/^${ipv4}[ \t][ \t]*/s/[0-9.]*[ \t]*//p" /etc/hosts | sed -e 's/[ \t]/; /g')
		echo "$interface $itype $ipv4 $hostname"
	done
}

if [ -r /var/env ]; then
	while read -r key value; do
		case $key in
			bootloaderVersion) loaderversion=$value ;;
			my_ipaddress)      ip_init_address=$value ;;
			maca)              mac_lan=$value ;;
			macdsl)            mac_dsl=$value ;;
			macwlan)           mac_wlan=$value ;;
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
	cpu_family=$(sed -ne '/system type/ s/.*: //p' /proc/cpuinfo | sed 's/Ikanos Fusiv.*/IKS/')
	cpu_model=$(sed -ne '/cpu model/ s/.*: //p' /proc/cpuinfo)
	cpu_cores=$(grep $'^processor\t*:' /proc/cpuinfo | wc -l)
	cpu_bogom="$(sed -ne '/BogoMIPS/ s/.*: //p' /proc/cpuinfo)"
	cpu_bogom="$(echo $cpu_bogom | sed 's! ! / !g')"
	
else
	cpu_family=""
	cpu_model=""
	cpu_cores=""
	cpu_bogom=""
fi
if [ -r /etc/version ]; then
	avm_date=$(sed -ne 's/^export FIRMWARE_DATE\="\(.*\)"/\1/p' /etc/version)
else
	avm_date=$notdefined
fi
if [ -r /etc/.revision ]; then
	avm_revision=$(cat /etc/.revision)
elif [ -r /etc/version ]; then
	avm_revision="$(sed -n '/--project)$/{N;s/.*echo //p}' /etc/version)"
else
	avm_revision=$notdefined
fi

if [ -r /proc/sys/urlader/environment ]; then
	flash_size=$(sed -ne "s/^flashsize.\([0-9x].*\)/\1/p" /proc/sys/urlader/environment)
	case "$flash_size" in
		0x*)    flash_size=$(($flash_size / 0x100000));;
		*)      flash_size="";;
	esac
fi
if [ -z $flash_size -a "${CONFIG_ROMSIZE#*=}" == "${CONFIG_ROMSIZE%=*}" ]; then
	flash_size="$CONFIG_ROMSIZE"
fi
_CONFIG_NAND="$(echo $CONFIG_ROMSIZE | sed -ne "s/^.*sflash_size=\([0-9]*\).*/\1/p")"
_CONFIG_TFFS="$(echo $CONFIG_ROMSIZE | sed -ne "s/^.*nand_size=\([0-9]*\).*/\1/p")"
[ $(which run_clock) ] && run_clock=$(run_clock | sed 's/.*: //')

sec_begin '$(lang de:"Hardware-Informationen" en:"Information about hardware")'

echo "<dl class='info'>"
echo "<dt>$(lang de:"Boxname" en:"Box name")</dt><dd>$CONFIG_PRODUKT_NAME</dd>"
echo "<dt>ANNEX</dt><dd>$ANNEX</dd>"
echo "</dl>"

echo "<dl class='info'>"
echo "<dt>HWRevision</dt><dd>$HWRevision.$(($HWRevision_ATA)).$((HWRevision_BitFileCount)).$(($HWRevision_Reserved1))</dd>"
[ -n "$flash_size" ] && echo "<dt>Flash (ROM)</dt><dd>$flash_size MB</dd>"
echo "<dt>RAM</dt><dd>$CONFIG_RAMSIZE MB</dd>"
echo "</dl>"

if [ -n "$_CONFIG_NAND$_CONFIG_TFFS" ]; then
echo "<dl class='info'>"
echo "<dt>NAND</dt><dd>$_CONFIG_NAND</dd>"
echo "<dt>TFFS</dt><dd>$_CONFIG_TFFS</dd>"
echo "</dl>"
fi

echo "<dl class='info'>"
[ -n "$cpu_family" ] && echo "<dt>CPU$(lang de:"-Familie" en:" family")</dt><dd>$cpu_family</dd>"
[ -n "$cpu_model"  ] && echo "<dt>CPU$(lang de:"-Modell"  en:" model" )</dt><dd>$cpu_model</dd>"
[ -n "$cpu_cores"  ] && echo "<dt>CPU$(lang de:"-Kerne" en:" cores" )</dt><dd>$cpu_cores</dd>"

echo "</dl>"

if [ -e /proc/clocks -o -e /proc/sys/urlader/environment ]; then
	echo "<dl class='info'>"
	echo "<dt>$(lang de:"Taktfrequenzen" en:"Clock frequencies")</dt><dl>"
	if [ -e /proc/clocks ]; then
			sed 's/ [ ]*/ /g;s/^Clocks: //;s/^[A-Z0-9 ]*Clock: //;s/\([A-Za-z0-9]*\):[ ]*\([0-9,.]*\)[ ]*\([a-zA-Z]*\) */<dt>\1<\/dt><dd>\2 \3<\/dd>/g;' /proc/clocks 2>/dev/null
	else
		_CPU_FRQ="$(sed -n 's/^cpufrequency\t//p' /proc/sys/urlader/environment | awk '{ printf "%.0f", $1 /1000/1000 }')"
		_SYS_FRQ="$(sed -n 's/^sysfrequency\t//p' /proc/sys/urlader/environment | awk '{ printf "%.0f", $1 /1000/1000 }')"
		echo "<dt>CPU</dt><dd>$_CPU_FRQ MHz</dd>"
		echo "<dt>SYSTEM</dt><dd>$_SYS_FRQ MHz</dd>"
	fi
	[ -n "$cpu_bogom" ] && echo "<dt>BogoMIPS</dt><dd>$cpu_bogom</dd>"
	echo "</dl>"
	echo "</dl>"
fi

if [ -n "$run_clock" ]; then
	echo "<dl class='info'>"
	echo "<dt>$(lang de:"Betriebsstundenz&auml;hler" en:"Operating hours counter")</dt><dd>$run_clock</dd>"
	echo "</dl>"
fi

sec_end

sec_begin '$(lang de:"Netzwerk" en:"Network")'

host_name=$(hostname)
ext_name="$(sed 's/.*[ \t]//g' /var/tmp/ddnsstat.txt 2>/dev/null | sort -u)"
act_ip=$(hostname -i)
pubip="$(/usr/bin/get_ip)"
echo '<table width="100%"><tr><td><b>$(lang de:"Netze" en:"Networks"):</b></td>'
echo '<td><b><small>IP-$(lang de:"Adresse" en:"Address")</small></b></td>'
echo '<td><b><small>Hostname</small></b></td></tr>'
if [ -n "$pubip" ]; then
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

echo "<dl class='info'>"
echo "<dt>MAC$(lang de:"-Adressen" en:" address")</dt><dd><dl>"
echo "<dt>DSL</dt><dd><small>$mac_dsl</small></dd>"
echo "<dt>LAN</dt><dd><small>$mac_lan</small></dd>"
echo "<dt>WLAN</dt><dd><small>$mac_wlan</small></dd>"
echo "</dl></dd></dl>"

sec_end

avsar_ver=/proc/avalanche/avsar_ver
if [ -r "$avsar_ver" ]; then
	sec_begin '$(lang de:"DSL-Treiber und Hardware" en:"DSL drivers and hardware")'
		echo "<pre class='plain'>$(cat "$avsar_ver")</pre>"
	sec_end
fi

sec_begin '$(lang de:"Firmware-Informationen" en:"Information about firmware")'

echo "<dl class='info'>"
echo "<dt>Firmware$(lang de:"" en:" ")version</dt><dd>${CONFIG_VERSION_MAJOR}.${CONFIG_VERSION}"
echo "<dt>AVM-Revision</dt><dd>$avm_revision</dd>"
echo "<dt>$(lang de:"Sprache" en:"Language")</dt><dd>$Language</dd>"
echo "</dl>"

echo "<dl class='info'>"
echo "<dt>$(lang de:"Erstellungsdatum" en:"Compilation date") (AVM)</dt><dd>$avm_date</dd>"
echo "</dl>"

echo "<dl class='info'>"
echo "<dt>$(lang de:"Bootloaderversion" en:"Version of bootloader")</dt><dd>$loaderversion</dd>"
echo "</dl>"

sec_end

if [ -r /var/env.cache ]; then
	sec_begin '$(lang de:"Umgebungsvariablen" en:"Environment variables")'
		echo -n '<div class="textwrapper"><textarea style="margin-top:6px;" name="content" rows="5" cols="10" wrap="off" readonly>'
		sed -e "s/^export //g" /var/env.cache | html
		echo -n '</textarea></div>'
	sec_end
fi
