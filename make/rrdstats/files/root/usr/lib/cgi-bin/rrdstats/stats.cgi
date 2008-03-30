#!/bin/sh

# modified by cuma
# file: rrdstat.cgi
# created by ramik 11/02/2008
#
# cgi script to display collected statistics on the Freetz interface

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

. /mod/etc/conf/rrdstats.cfg

URL_STATUS="?pkg=rrdstats&cgi=rrdstats/stats"
URL_EXTENDED="$SCRIPT_NAME$URL_STATUS"
DATESTRING=`date +'%d/%m/%y %X'`
let WIDTH="$_cgi_width-298"
let HEIGHT=$WIDTH/3
PERIODE='24h'
RED=#EA644A
YELLOW=#ECD748
GREEN=#54EC48
BLUE=#48C4EC
RED_D=#CC3118
ORANGE_D=#CC7016
BLACK=#000000
LOGARITHMIC="$RRDSTATS_NET_ADVANCE"

has_swap() {
	[ "$(free | grep "Swap:" | awk '{print $2}')" == "0" ] || return 0
	return 1
}

generate_graph() {
	if [ -n "$2" ]; then
		IMAGENAME=$1-$2
		PERIODE=$2
	else
		IMAGENAME=$1
	fi
	
	case $1 in
		cpu)
			NAMEPREFIX=cpu
			FILE=$RRDSTATS_RRDDATA/$NAMEPREFIX.rrd
			if [ -e $FILE ]; then
				rrdtool graph  $RRDSTATS_RRDTEMP/$IMAGENAME.png	\
				--title "CPU Usage"			\
				--start now-$PERIODE			\
				--width $WIDTH --height $HEIGHT		\
				--vertical-label "CPU usage [%]"	\
				--color SHADEA#ffffff			\
				--color SHADEB#ffffff			\
				--color BACK#ffffff			\
				--color CANVAS#eeeeee80			\
				-l 0 -u 100 -r -z			\
				-W "Generated on: $DATESTRING"		\
									\
				DEF:user=$FILE:user:AVERAGE		\
				DEF:nice=$FILE:nice:AVERAGE		\
				DEF:syst=$FILE:syst:AVERAGE		\
				DEF:wait=$FILE:wait:AVERAGE		\
				DEF:idle=$FILE:idle:AVERAGE		\
				CDEF:cpu=user,nice,syst,wait,+,+,+ 	\
							   		\
				AREA:wait$RED:"CPU wait"		\
				AREA:syst$GREEN:"CPU system":STACK	\
				AREA:nice$YELLOW:"CPU nice":STACK	\
				AREA:user$BLUE:"CPU user\n":STACK	\
									\
				LINE1:cpu$BLACK				\
				COMMENT:"Averaged CPU usage (min/avg/cur)\:"	\
				GPRINT:cpu:MIN:"%2.1lf%% /"		\
				GPRINT:cpu:AVERAGE:"%2.1lf%% /"		\
				GPRINT:cpu:LAST:"%2.1lf%%\n"		> /dev/null
			fi
			;;
		memory)
			NAMEPREFIX=memory 
			let RAM=`grep MemTotal /proc/meminfo | tr -s [:blank:] " " |cut -d " " -f 2`*1024
			FILE=$RRDSTATS_RRDDATA/$NAMEPREFIX.rrd
			if [ -e $FILE ]; then
				rrdtool graph  $RRDSTATS_RRDTEMP/$IMAGENAME.png	\
				--title "Memory Usage"			\
				--start now-$PERIODE -u $RAM -r -l 0 -z	\
				--width $WIDTH --height $HEIGHT		\
				--vertical-label "allocation [bytes]"	\
				--color SHADEA#ffffff			\
				--color SHADEB#ffffff			\
				--color BACK#ffffff			\
				--color CANVAS#eeeeee80			\
				--base 1024 --units=si			\
				-W "Generated on: $DATESTRING"		\
									\
				DEF:used=$FILE:used:AVERAGE		\
				DEF:buff=$FILE:buff:AVERAGE		\
				DEF:cached=$FILE:cached:AVERAGE		\
				DEF:free=$FILE:free:AVERAGE		\
									\
				AREA:used$RED:"Used memory   (max/avg/cur)[bytes]\:" \
				LINE1:used$RED_D			\
				GPRINT:used:MAX:"%3.0lf%s /"		\
				GPRINT:used:AVERAGE:"%3.0lf%s /"	\
				GPRINT:used:LAST:"%3.0lf%s\n"		\
									\
				AREA:buff$BLUE:"Buffer memory (max/avg/cur)[bytes]\:":STACK \
				GPRINT:buff:MAX:"%3.0lf%s /"		\
				GPRINT:buff:AVERAGE:"%3.0lf%s /"	\
				GPRINT:buff:LAST:"%3.0lf%s\n"		\
									\
				AREA:cached$YELLOW:"Cache memory  (max/avg/cur)[bytes]\:":STACK \
				GPRINT:cached:MAX:"%3.0lf%s /"		\
				GPRINT:cached:AVERAGE:"%3.0lf%s /"	\
				GPRINT:cached:LAST:"%3.0lf%s\n"		\
									\
				AREA:free$GREEN:"Free memory   (max/avg/cur)[bytes]\:":STACK \
				GPRINT:free:MAX:"%3.0lf%s /"		\
				GPRINT:free:AVERAGE:"%3.0lf%s /"	\
				GPRINT:free:LAST:"%3.0lf%s\n"		> /dev/null

			fi
			;;
		swap)
			NAMEPREFIX=swap
			FILE=$RRDSTATS_RRDDATA/memory.rrd

			if [ -e $FILE ]; then
				rrdtool graph  $RRDSTATS_RRDTEMP/$NAMEPREFIX.png	\
				--title "Swap stats"			\
				--start -1-$PERIODE -l 0 -u 100 -r	\
				--width $WIDTH --height $HEIGHT	-z	\
				--vertical-label "Swap usage [%]"	\
				--color SHADEA#ffffff			\
				--color SHADEB#ffffff			\
				--color BACK#ffffff			\
				--color CANVAS#eeeeee80			\
				-W "Generated on: $DATESTRING"		\
									\
				DEF:total=$FILE:swaptotal:AVERAGE	\
				DEF:free=$FILE:swapfree:AVERAGE		\
				CDEF:used=total,free,-			\
				CDEF:usedpct=100,used,total,/,*		\
				CDEF:freepct=100,free,total,/,*		\
				AREA:usedpct#0000FF:"Used swap"		\
				GPRINT:usedpct:MAX:"%3.2lf%% maximal used swap"		\
				GPRINT:usedpct:AVERAGE:"%3.2lf%% average used swap"	\
				GPRINT:usedpct:LAST:"%3.2lf%% current used swap\j"	\
											\
				AREA:freepct#00FF00:"Free swap":STACK \
				GPRINT:freepct:MAX:"%3.2lf%% maximal free swap"		\
				GPRINT:freepct:AVERAGE:"%3.2lf%% average free swap"	\
				GPRINT:freepct:LAST:"%3.2lf%% current free swap\j"	> /dev/null
			fi

			;;
		wan)
			NAMEPREFIX=net
			FILE=$RRDSTATS_RRDDATA/${NAMEPREFIX}_${RRDSTATS_WANINTERFACE}.rrd
			if [ -e $FILE ]; then
				rrdtool graph  $RRDSTATS_RRDTEMP/$IMAGENAME.png	\
				--title "Interface Traffic"			\
				--start -1-$PERIODE $LOGARITHMIC -z		\
				--width $WIDTH --height $HEIGHT		\
				--vertical-label "bytes/s"		\
				--color SHADEA#ffffff			\
				--color SHADEB#ffffff			\
				--color BACK#ffffff			\
				--color CANVAS#eeeeee80			\
				--units=si			\
				-W "Generated on: $DATESTRING"		\
									\
				DEF:in=$FILE:in:AVERAGE                 \
				DEF:out=$FILE:out:AVERAGE		\
									\
				AREA:in$GREEN:"Incoming    (max/avg/cur)[bytes/s]\:" \
				GPRINT:in:MAX:"%3.0lf%s /"		\
				GPRINT:in:AVERAGE:"%3.0lf%s /"		\
				GPRINT:in:LAST:"%3.0lf%s\n"		\
									\
				AREA:out#0000FF80:"Outgoing    (max/avg/cur)[bytes/s]\:"     \
				GPRINT:out:MAX:"%3.0lf%s /"		\
				GPRINT:out:AVERAGE:"%3.0lf%s /"		\
				GPRINT:out:LAST:"%3.0lf%s\n"		> /dev/null
			fi
			;;

		*)
			echo "error"
			;;
	esac
	return 1
}

#let _cgi_width=910

#####################################!!
graph="$(echo "$QUERY_STRING" | sed -e 's/^.*graph=//' -e 's/&.*$//' -e 's/\.//g')"
#####################################!!

#echo "Graph for: ${graph}"

#cgi_begin "RRDstats ${graph}" 'status_rrdstats'

case "$graph" in
	cpu|memory|wan|swap)
		generate_graph "$graph"
		generate_graph "$graph" "1w"
		generate_graph "$graph" "1m"
		generate_graph "$graph" "1y"
		sec_begin "$graph for last day"
		echo "<img src=\"/statpix/$graph.png\" alt=\"$graph for last day\" />"
		sec_end

		sec_begin "$graph for last week"
		echo "<img src=\"/statpix/$graph-1w.png\" alt=\"$graph for last week\" />"
		sec_end

		sec_begin "$graph for last month"
		echo "<img src=\"/statpix/$graph-1m.png\" alt=\"$graph for last month\" />"
		sec_end

		sec_begin "$graph for last year"
		echo "<img src=\"/statpix/$graph-1y.png\" alt=\"$graph for last year\" />"
		sec_end

cat << EOF
<br><input type="button" value="Back" onclick="history.go(-1)" />
EOF

		;;
	*)

sec_begin 'CPU'

generate_graph "cpu"

cat << EOF
<a href="$URL_EXTENDED&graph=cpu"><img src="/statpix/cpu.png" alt="CPU Load for $PERIODE" border="0"/></a>

EOF

sec_end

sec_begin 'Memory'

generate_graph "memory"

cat << EOF
<a href="$URL_EXTENDED&graph=memory"><img src="/statpix/memory.png" alt="Memory usage for $PERIODE" border="0"/></a>

EOF

sec_end

has_swap
if [ "$?" == "0" ]; then
sec_begin 'Swap'

generate_graph "swap"

cat << EOF
<a href="$URL_EXTENDED&graph=swap"><img src="/statpix/swap.png" alt="Swap usage for $PERIODE" border="0"/></a>

EOF
sec_end
fi


sec_begin 'Network'

generate_graph "wan"

cat << EOF
<a href="$URL_EXTENDED&graph=wan"><img src="/statpix/wan.png" alt="Interface Traffic for $PERIODE" border="0"/></a>

EOF

sec_end

		;;
esac

#cat << EOF
#<br><input type="button" value="Back" onclick="history.go(-1)" />
#EOF

#cgi_end
# End of file
