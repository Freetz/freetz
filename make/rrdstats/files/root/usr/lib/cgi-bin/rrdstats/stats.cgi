#!/bin/sh

# initial by ramik, extended by cuma

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /mod/etc/conf/rrdstats.cfg

URL_STATUS="?pkg=rrdstats&cgi=rrdstats/stats"
URL_EXTENDED="$SCRIPT_NAME$URL_STATUS"
DATESTRING=`date +'%d/%m/%y %X'`
let WIDTH="$_cgi_width-230-100"
let HEIGHT=$WIDTH*$RRDSTATS_DIMENSIONY/$RRDSTATS_DIMENSIONX
PERIODE='24h'
RED=#EA644A
YELLOW=#ECD748
GREEN=#54EC48
BLUE=#48C4EC
RED_D=#CC3118
ORANGE_D=#CC7016
BLACK=#000000
NOCACHE="?nocache=$(date -Iseconds|sed 's/T/_/g;s/+.*$//g;s/:/-/g')"
_NICE=$(which nice)

generate_graph() {
	TITLE=""
	[ $# -ge 4 ] && TITLE="$4"
	IMAGENAME="$3"
	PERIODE="$2"
	case $1 in
		cpu)
			FILE=$RRDSTATS_RRDDATA/cpu_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				[ "$RRDSTATS_CPU100PERC" = "yes" ] && CPU100PERC=" -u 100 -r "
				$_NICE rrdtool graph  $RRDSTATS_RRDTEMP/$IMAGENAME.png		\
				--title "$TITLE"						\
				--start now-$PERIODE						\
				--width $WIDTH --height $HEIGHT					\
				--vertical-label "CPU usage [%]"				\
				--color SHADEA#ffffff						\
				--color SHADEB#ffffff						\
				--color BACK#ffffff						\
				--color CANVAS#eeeeee80						\
				-l 0 $CPU100PERC $LAZY						\
				-W "Generated on: $DATESTRING"					\
												\
				DEF:user=$FILE:user:AVERAGE					\
				DEF:nice=$FILE:nice:AVERAGE					\
				DEF:syst=$FILE:syst:AVERAGE					\
				DEF:wait=$FILE:wait:AVERAGE					\
				DEF:idle=$FILE:idle:AVERAGE					\
				CDEF:cpu=user,nice,syst,wait,+,+,+ 				\
							   					\
				AREA:wait$RED:"CPU wait"					\
				AREA:syst$GREEN:"CPU system":STACK				\
				AREA:nice$YELLOW:"CPU nice":STACK				\
				AREA:user$BLUE:"CPU user\n":STACK				\
												\
				LINE1:cpu$BLACK							\
				COMMENT:"Averaged CPU usage (min/avg/cur)\:"			\
				GPRINT:cpu:MIN:"%2.1lf%% /"					\
				GPRINT:cpu:AVERAGE:"%2.1lf%% /"					\
				GPRINT:cpu:LAST:"%2.1lf%%\n"		> /dev/null
			fi
			;;
		mem)
			FILE=$RRDSTATS_RRDDATA/mem_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				let RAM=`grep MemTotal /proc/meminfo | tr -s [:blank:] " " |cut -d " " -f 2`*1024
				$_NICE rrdtool graph  $RRDSTATS_RRDTEMP/$IMAGENAME.png		\
				--title "$TITLE"						\
				--start now-$PERIODE -u $RAM -r -l 0 $LAZY			\
				--width $WIDTH --height $HEIGHT					\
				--vertical-label "allocation [bytes]"				\
				--color SHADEA#ffffff						\
				--color SHADEB#ffffff						\
				--color BACK#ffffff						\
				--color CANVAS#eeeeee80						\
				--base 1024 --units=si						\
				-W "Generated on: $DATESTRING"					\
												\
				DEF:used=$FILE:used:AVERAGE					\
				DEF:buff=$FILE:buff:AVERAGE					\
				DEF:cached=$FILE:cached:AVERAGE					\
				DEF:free=$FILE:free:AVERAGE					\
												\
				AREA:used$RED:"Used memory   (max/avg/cur)[bytes]\:"		\
				LINE1:used$RED_D						\
				GPRINT:used:MAX:"%3.0lf%s /"					\
				GPRINT:used:AVERAGE:"%3.0lf%s /"				\
				GPRINT:used:LAST:"%3.0lf%s\n"					\
												\
				AREA:buff$BLUE:"Buffer memory (max/avg/cur)[bytes]\:":STACK	\
				GPRINT:buff:MAX:"%3.0lf%s /"					\
				GPRINT:buff:AVERAGE:"%3.0lf%s /"				\
				GPRINT:buff:LAST:"%3.0lf%s\n"					\
												\
				AREA:cached$YELLOW:"Cache memory  (max/avg/cur)[bytes]\:":STACK	\
				GPRINT:cached:MAX:"%3.0lf%s /"					\
				GPRINT:cached:AVERAGE:"%3.0lf%s /"				\
				GPRINT:cached:LAST:"%3.0lf%s\n"					\
												\
				AREA:free$GREEN:"Free memory   (max/avg/cur)[bytes]\:":STACK	\
				GPRINT:free:MAX:"%3.0lf%s /"					\
				GPRINT:free:AVERAGE:"%3.0lf%s /"				\
				GPRINT:free:LAST:"%3.0lf%s\n"				> /dev/null

			fi
			;;
		upt)
			FILE=$RRDSTATS_RRDDATA/upt_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph  $RRDSTATS_RRDTEMP/$IMAGENAME.png		\
				--title "$TITLE"						\
				--start -1-$PERIODE -l 0 -r					\
				--width $WIDTH --height $HEIGHT $LAZY				\
				--vertical-label "Uptime [h]" -X 1				\
				--color SHADEA#ffffff						\
				--color SHADEB#ffffff						\
				--color BACK#ffffff						\
				--color CANVAS#eeeeee80						\
				-W "Generated on: $DATESTRING"					\
												\
				DEF:uptime=$FILE:uptime:MAX					\
												\
				AREA:uptime$YELLOW:"Uptime (maximal/current)[hours]\:   ":STACK	\
				GPRINT:uptime:MAX:"%3.2lf /"					\
				GPRINT:uptime:LAST:"%3.2lf\n"				> /dev/null
			fi
			;;
		swap)
			FILE=$RRDSTATS_RRDDATA/mem_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph  $RRDSTATS_RRDTEMP/$IMAGENAME.png		\
				--title "$TITLE"						\
				--start -1-$PERIODE -l 0 -u 100 -r				\
				--width $WIDTH --height $HEIGHT	$LAZY				\
				--vertical-label "Swap usage [%]"				\
				--color SHADEA#ffffff						\
				--color SHADEB#ffffff						\
				--color BACK#ffffff						\
				--color CANVAS#eeeeee80						\
				-W "Generated on: $DATESTRING"					\
												\
				DEF:total=$FILE:swaptotal:AVERAGE				\
				DEF:free=$FILE:swapfree:AVERAGE					\
				CDEF:used=total,free,-						\
				CDEF:usedpct=100,used,total,/,*					\
				CDEF:freepct=100,free,total,/,*					\
				AREA:usedpct#0000FF:"Used swap"					\
				GPRINT:usedpct:MAX:"%3.2lf%% maximal used swap"			\
				GPRINT:usedpct:AVERAGE:"%3.2lf%% average used swap"		\
				GPRINT:usedpct:LAST:"%3.2lf%% current used swap\j"		\
												\
				AREA:freepct#00FF00:"Free swap":STACK				\
				GPRINT:freepct:MAX:"%3.2lf%% maximal free swap"			\
				GPRINT:freepct:AVERAGE:"%3.2lf%% average free swap"		\
				GPRINT:freepct:LAST:"%3.2lf%% current free swap\j"	> /dev/null
			fi
			;;
		if1|if2|if3|if4)
			case $1 in
				if1)
					IF=$RRDSTATS_INTERFACE1
					XG=$RRDSTATS_XCHG_RXTX1
					LG=$RRDSTATS_LOGARITHM1
					MX=$RRDSTATS_MAX_GRAPH1
					;;
				if2)
					IF=$RRDSTATS_INTERFACE2
					XG=$RRDSTATS_XCHG_RXTX2
					LG=$RRDSTATS_LOGARITHM2
					MX=$RRDSTATS_MAX_GRAPH2
					;;
				if3)
					IF=$RRDSTATS_INTERFACE3
					XG=$RRDSTATS_XCHG_RXTX3
					LG=$RRDSTATS_LOGARITHM3
					MX=$RRDSTATS_MAX_GRAPH3
					;;
				if4)
					IF=$RRDSTATS_INTERFACE4
					XG=$RRDSTATS_XCHG_RXTX4
					LG=$RRDSTATS_LOGARITHM4
					MX=$RRDSTATS_MAX_GRAPH4
					;;
			esac

			if [ "$XG" = "yes" ]; then
				NET_RX="out"
				NET_TX="in"
			else
				NET_RX="in"
				NET_TX="out"
			fi

			if [ "$LG" = "yes" ]; then
				LOGARITHMIC=" -o "
			else
				LOGARITHMIC=" -l 0 "
			fi

			if [ -z "$MX" -o "$MX" -eq 0 ]; then
				MAXIMALBW=""
			else
				let MAXIMALBW=$MX*1000*1000/8
				MAXIMALBW=" -r -u $MAXIMALBW "
			fi

			FILE=$RRDSTATS_RRDDATA/$1_$RRDSTATS_INTERVAL-$(echo $IF|sed 's/\:/_/g').rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph  $RRDSTATS_RRDTEMP/$IMAGENAME.png		\
				--title "$TITLE"						\
				--start -1-$PERIODE $LOGARITHMIC $LAZY $MAXIMALBW		\
				--width $WIDTH --height $HEIGHT					\
				--vertical-label "bytes/s"					\
				--color SHADEA#ffffff						\
				--color SHADEB#ffffff						\
				--color BACK#ffffff						\
				--color CANVAS#eeeeee80						\
				--units=si							\
				-W "Generated on: $DATESTRING"					\
												\
				DEF:in=$FILE:$NET_RX:AVERAGE					\
				DEF:out=$FILE:$NET_TX:AVERAGE					\
												\
				AREA:in$GREEN:"Incoming    (max/avg/cur)[bytes/s]\:"		\
				GPRINT:in:MAX:"%3.0lf%s /"					\
				GPRINT:in:AVERAGE:"%3.0lf%s /"					\
				GPRINT:in:LAST:"%3.0lf%s\n"					\
												\
				AREA:out#0000FF80:"Outgoing    (max/avg/cur)[bytes/s]\:"	\
				GPRINT:out:MAX:"%3.0lf%s /"					\
				GPRINT:out:AVERAGE:"%3.0lf%s /"					\
				GPRINT:out:LAST:"%3.0lf%s\n"		> /dev/null
			fi
			;;

		*)
			echo "error"
			;;
	esac
	return 1
}

set_lazy() {
	LAZY=" "
	[ "$1" = "no" ] && LAZY=" -z "
}

set_period() {
	periodA=$(echo $1|sed 's/[0-9]\+h/hour/g;s/[0-9]\+d$/day/g;s/[0-9]\+w$/week/g;s/[0-9]\+m$/month/g;s/[0-9]\+y$/year/g')
	period0=$(echo $1|sed 's/[a-zA-Z]//g')
	periodG=${period0}${periodA}s
	if [ $period0 -gt 1 ]; then
		periodA=" $periodA"s
	else
		period0=""
	fi
	periodnn=$period0$periodA
}

gen_main() {
	SNAME=$1
	FNAME=$2
	LAPSE=$3
	sec_begin "$FNAME "
	generate_graph "$SNAME" "$RRDSTATS_PERIODMAIN" "$SNAME" "" 
	echo "<a href=\"$URL_EXTENDED&graph=$SNAME\"><img src=\"/statpix/$SNAME.png$NOCACHE\" alt=\"$FNAME stats for last $LAPSE\" border=\"0\"/></a>"
	sec_end
}

graph="$(echo "$QUERY_STRING" | sed -e 's/^.*graph=//' -e 's/&.*$//' -e 's/\.//g')"
case "$graph" in
	cpu|mem|swap|upt|if1|if2|if3|if4)
		set_lazy "$RRDSTATS_NOTLAZYS"
		heading=$(echo $graph|sed "s/^upt$/Uptime/g;s/^cpu$/Processor/g;s/^mem$/Memory/g;s/^swap$/Swapspace/g;s/^if1$/$RRDSTATS_NICE_NAME1/g;s/^if2$/$RRDSTATS_NICE_NAME2/g;s/^if3$/$RRDSTATS_NICE_NAME3/g;s/^if4$/$RRDSTATS_NICE_NAME4/g")
		echo "<center><font size=+1><b>$heading stats</b></font></center>"
		for period in $RRDSTATS_PERIODSSUB; do
			set_period $period
			sec_begin ""
			generate_graph "$graph" "$period" "$graph-$period" "last $periodnn"
			echo "<img src=\"/statpix/$graph-$period.png$NOCACHE\" alt=\"$heading stats for last $periodnn\" />"
			sec_end
		done
		echo "<br><input type=\"button\" value=\"Back\" onclick=\"history.go(-1)\" />"
		;;
	*)
		set_lazy "$RRDSTATS_NOTLAZYM"
		set_period "$RRDSTATS_PERIODMAIN"
		echo "<center><font size=+1><b>Stats for last $periodnn</b></font></center>"
		gen_main "cpu" "Processor" "$periodnn"
		gen_main "mem" "Memory" "$periodnn"
		[ "$(free | grep "Swap:" | awk '{print $2}')" != "0" ] && gen_main "swap" "Swapspace" "$periodnn"
		[ "$RRDSTATS_UPTIME_ENB" = yes ] && gen_main "upt" "Uptime" "$periodnn"
		[ ! -z "$RRDSTATS_INTERFACE1" ] && gen_main "if1" "$RRDSTATS_NICE_NAME1" "$periodnn"
		[ ! -z "$RRDSTATS_INTERFACE2" ] && gen_main "if2" "$RRDSTATS_NICE_NAME2" "$periodnn"
		[ ! -z "$RRDSTATS_INTERFACE3" ] && gen_main "if3" "$RRDSTATS_NICE_NAME3" "$periodnn"
		[ ! -z "$RRDSTATS_INTERFACE4" ] && gen_main "if4" "$RRDSTATS_NICE_NAME4" "$periodnn"
		;;
esac

