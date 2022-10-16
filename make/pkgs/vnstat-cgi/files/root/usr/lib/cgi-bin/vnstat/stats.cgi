#!/bin/sh
#by cuma


. /mod/etc/conf/vnstat.cfg

_NICE=$(which nice)
NOCACHE="?nocache=$(date -Iseconds | sed 's/T/_/g;s/+.*$//g;s/:/-/g')"
TEMPDIR=/tmp/vnstat
mkdir -p $TEMPDIR

gen_pic() {
	$_NICE vnstati -i $1 --$2 -o $TEMPDIR/$1-$2.png --config /tmp/flash/vnstat/vnstat.conf
	echo "<p><img src=\"/vnspix/$1-$2.png$NOCACHE\" alt=\"vnstat: $2 of $1\" border=\"0\"/></p>"
}

#main
echo "<center>"
netif=$(cgi_param netif)

#count ifs
ifcnt=0
for ifname in $VNSTAT_INTERFACES; do
	let ifcnt++
done
[ $ifcnt -eq 1 ] && netif=$VNSTAT_INTERFACES

#show pix
if [ -n "$netif" ]; then
	#subpages
	echo "<p><font size=+1><b>vnstat: $netif</b></font></p>"
	for period in summary hours days months top10; do
		[ $ifcnt -ne 1 ] && echo "<a href=\"$SCRIPT_NAME\" class='image'>"
		gen_pic $netif $period
		[ $ifcnt -ne 1 ] && echo "</a>"
	done
	if [ $ifcnt -ne 1 ]; then
		[ -n "$HTTP_REFERER" ] && backdest="history.go(-1)" || backdest="window.location.href='$SCRIPT_NAME'"
		echo "<br><input type=\"button\" value=\"Back\" onclick=\"javascript:$backdest\" />"
	fi
else
	#mainpage
	echo "<p><font size=+1><b>vnstat</b></font></p>"
	[ -z "$VNSTAT_INTERFACES" ] && VNSTAT_INTERFACES=$(ls /var/lib/vnstat/ 2>/dev/null)
	for dbfile in $VNSTAT_INTERFACES; do
		echo "<a href=\"$SCRIPT_NAME?netif=$dbfile\" class='image'>"
		gen_pic $dbfile summary
		echo "</a>"
	done
fi

echo "</center>"
