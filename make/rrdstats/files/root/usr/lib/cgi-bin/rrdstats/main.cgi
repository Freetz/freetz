#!/bin/sh

# initially by ramik, extended by cuma


. /mod/etc/conf/rrdstats.cfg
[ -r /etc/options.cfg ] && . /etc/options.cfg

DATESTRING=$(date -R)
[ -n "$_cgi_width" ] && let WIDTH=_cgi_width-145 || let WIDTH=500
GROUP_PERIOD="$(cgi_param group | tr -d .)"
ALL_GRAPHS="$(cgi_param graph | tr -d .)"
while [ $# -gt 0 ]; do
	case "$1" in
		-graph=*)
			ALL_GRAPHS="$ALL_GRAPHS ${1#*=}"
			;;
		-group=*)
			GROUP_PERIOD="${1#*=}"
			;;
		-width=*)
			WIDTH="${1#*=}"
			;;
		-period=*)
			PERIOD_ARG="$PERIOD_ARG ${1#*=}"
			;;
		-not-lazy)
			NOTLAZY="1"
			;;
	esac
	shift
done
[ -z "$ALL_GRAPHS" ] && ALL_GRAPHS="mainpage"

let HEIGHT=$WIDTH*$RRDSTATS_DIMENSIONY/$RRDSTATS_DIMENSIONX
PERIODE="24h"
RED=#EA644A
DARKRED=#FF0000
YELLOW=#ECD748
GREEN=#54EC48
BLUE=#48C4EC
LRED=#FF7F7F
LYELLOW=#DCDC00
LGREEN=#7FFF7F
LBLUE=#7F7FFF
PURPLE=#A349A4
LPURPLE=#4A6997
RED_D=#CC3118
ORANGE_D=#CC7016
BLACK=#000000
GREY=#7F7F7F
NBSP="$(echo -e '\240')"
NOCACHE="?nocache=$(date -Iseconds | sed 's/T/_/g;s/+.*$//g;s/:/-/g')"
_NICE=$(which nice)
DEFAULT_COLORS="--color SHADEA#ffffff --color SHADEB#ffffff --color BACK#ffffff --color CANVAS#eeeeee80"

generate_graph() {
	TITLE=""
	[ $# -ge 4 ] && TITLE=$4
	IMAGENAME=$3
	[ $# -ge 5 ] && IMAGENAME="$3$5"
	PERIODE=$2
	case $1 in
		cpu)
			FILE=$RRDSTATS_RRDDATA/cpu_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				[ "$RRDSTATS_CPU100PERC" = "yes" ] && CPU100PERC=" -u 100 -r "
				$_NICE rrdtool graph                             \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                 \
				--title "$TITLE"                                 \
				--start now-$PERIODE                             \
				--width $WIDTH --height $HEIGHT                  \
				--vertical-label "CPU usage [%]"                 \
				$DEFAULT_COLORS                                  \
				-l 0 $CPU100PERC $LAZY                           \
				-W "Generated on: $DATESTRING"                   \
				                                                 \
				DEF:user=$FILE:user:AVERAGE                      \
				DEF:nice=$FILE:nice:AVERAGE                      \
				DEF:syst=$FILE:syst:AVERAGE                      \
				DEF:wait=$FILE:wait:AVERAGE                      \
				DEF:idle=$FILE:idle:AVERAGE                      \
				CDEF:cpu=user,nice,syst,wait,+,+,+               \
				                                                 \
				AREA:wait$RED:"CPU wait"                         \
				AREA:syst$GREEN:"CPU system":STACK               \
				AREA:nice$YELLOW:"CPU nice":STACK                \
				AREA:user$BLUE:"CPU user\n":STACK                \
				                                                 \
				LINE1:cpu$BLACK                                  \
				COMMENT:"Averaged CPU usage (min/avg/max/cur)\:" \
				GPRINT:cpu:MIN:"%2.1lf%% /"                      \
				GPRINT:cpu:AVERAGE:"%2.1lf%% /"                  \
				GPRINT:cpu:MAX:"%2.1lf%% /"                      \
				GPRINT:cpu:LAST:"%2.1lf%%\n"                     > /dev/null
			fi
			;;
		mem)
			FILE=$RRDSTATS_RRDDATA/mem_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				let RAM=$(grep MemTotal /proc/meminfo | tr -s [:blank:] " " | cut -d " " -f 2)*1024
				$_NICE rrdtool graph                                                \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                                    \
				--title "$TITLE"                                                    \
				--start now-$PERIODE -u $RAM -r -l 0 $LAZY                          \
				--width $WIDTH --height $HEIGHT                                     \
				--vertical-label "allocation [bytes]"                               \
				$DEFAULT_COLORS                                                     \
				--base 1024 --units=si                                              \
				-W "Generated on: $DATESTRING"                                      \
				                                                                    \
				DEF:used=$FILE:used:AVERAGE                                         \
				DEF:buff=$FILE:buff:AVERAGE                                         \
				DEF:cached=$FILE:cached:AVERAGE                                     \
				DEF:free=$FILE:free:AVERAGE                                         \
				                                                                    \
				AREA:used$RED:"Used memory   (min/avg/max/cur)[bytes]\:"            \
				LINE1:used$RED_D                                                    \
				GPRINT:used:MIN:"%3.0lf%s /"                                        \
				GPRINT:used:AVERAGE:"%3.0lf%s /"                                    \
				GPRINT:used:MAX:"%3.0lf%s /"                                        \
				GPRINT:used:LAST:"%3.0lf%s\n"                                       \
				                                                                    \
				AREA:buff$BLUE:"Buffer memory (min/avg/max/cur)[bytes]\:":STACK     \
				GPRINT:buff:MIN:"%3.0lf%s /"                                        \
				GPRINT:buff:AVERAGE:"%3.0lf%s /"                                    \
				GPRINT:buff:MAX:"%3.0lf%s /"                                        \
				GPRINT:buff:LAST:"%3.0lf%s\n"                                       \
				                                                                    \
				AREA:cached$YELLOW:"Cache memory  (min/avg/max/cur)[bytes]\:":STACK \
				GPRINT:cached:MIN:"%3.0lf%s /"                                      \
				GPRINT:cached:AVERAGE:"%3.0lf%s /"                                  \
				GPRINT:cached:MAX:"%3.0lf%s /"                                      \
				GPRINT:cached:LAST:"%3.0lf%s\n"                                     \
				                                                                    \
				AREA:free$GREEN:"Free memory   (min/avg/max/cur)[bytes]\:":STACK    \
				GPRINT:free:MIN:"%3.0lf%s /"                                        \
				GPRINT:free:AVERAGE:"%3.0lf%s /"                                    \
				GPRINT:free:MAX:"%3.0lf%s /"                                        \
				GPRINT:free:LAST:"%3.0lf%s\n"                                       > /dev/null
			fi
			;;
		upt)
			FILE=$RRDSTATS_RRDDATA/upt_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                      \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                          \
				--title "$TITLE"                                          \
				--start -1-$PERIODE -l 0 -r                               \
				--width $WIDTH --height $HEIGHT $LAZY                     \
				--vertical-label "hours" -X 1                             \
				$DEFAULT_COLORS                                           \
				-W "Generated on: $DATESTRING"                            \
				                                                          \
				DEF:uptime=$FILE:uptime:MAX                               \
                                                                          \
				AREA:uptime$YELLOW:"Uptime (min/avg/max/cur)[hours]\:   " \
				GPRINT:uptime:MIN:"%3.2lf /"                              \
				GPRINT:uptime:AVERAGE:"%3.2lf /"                          \
				GPRINT:uptime:MAX:"%3.2lf /"                              \
				GPRINT:uptime:LAST:"%3.2lf\n"                             > /dev/null
			fi
			;;
		temp)
			FILE=$RRDSTATS_RRDDATA/temp_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                        \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                            \
				--title "$TITLE"                                            \
				--start -1-$PERIODE -l 0 -r                                 \
				--width $WIDTH --height $HEIGHT $LAZY                       \
				--vertical-label "celsius" -X 1                             \
				$DEFAULT_COLORS                                             \
				-W "Generated on: $DATESTRING"                              \
				                                                            \
				DEF:temperature=$FILE:temperature:MAX                       \
				                                                            \
				AREA:temperature$RED:"Temperature (min/avg/max/cur)\:   "   \
				GPRINT:temperature:MIN:"%3.0lf /"                           \
				GPRINT:temperature:AVERAGE:"%3.0lf /"                       \
				GPRINT:temperature:MAX:"%3.0lf /"                           \
				GPRINT:temperature:LAST:"%3.0lf\n"                          > /dev/null
			fi
			;;
		epc0)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				local DS_DEF=''

				count=0
				local GPRINT_TXDB=''
				local GPRINT_TXFQ=''
				while [ $count -lt $RRDSTATS_CISCOEPC_TX ]; do
					let count++
					DS_DEF="$DS_DEF \
						DEF:txfq$count=$FILE:txfq$count:LAST \
						DEF:txdb$count=$FILE:txdb$count:LAST "
					COLOR_DB=$GREEN && COLOR_FQ=$RED
					GPRINT_TXDB="$GPRINT_TXDB \
						LINE3:txdb$count$COLOR_DB:Upstream${NBSP}SIG${NBSP}#${count}${NBSP}(min/avg/max/cur)[dBmV]\:\t\t \
						GPRINT:txdb$count:MIN:%4.1lf\t/ \
						GPRINT:txdb$count:AVERAGE:%4.1lf\t/ \
						GPRINT:txdb$count:MAX:%4.1lf\t/ \
						GPRINT:txdb$count:LAST:%4.1lf\n "
					GPRINT_TXFQ="$GPRINT_TXFQ \
						LINE3:txfq$count$COLOR_FQ:Upstream${NBSP}Frequency${NBSP}#${count}${NBSP}(min/avg/max/cur)[MHz]\:\t \
						GPRINT:txfq$count:MIN:%4.1lf\t/ \
						GPRINT:txfq$count:AVERAGE:%4.1lf\t/ \
						GPRINT:txfq$count:MAX:%4.1lf\t/ \
						GPRINT:txfq$count:LAST:%4.1lf\n "
				done

				count=0
				local GPRINT_RXSN=''
				local GPRINT_RXDB=''
				while [ $count -lt $RRDSTATS_CISCOEPC_RX ]; do
					let count++
					DS_DEF="$DS_DEF \
						DEF:rxsn$count=$FILE:rxsn$count:LAST \
						DEF:rxdb$count=$FILE:rxdb$count:LAST "
					COLOR_SN=$YELLOW && COLOR_DB=$BLUE
					GPRINT_RXSN="$GPRINT_RXSN \
						LINE3:rxsn$count$COLOR_SN:Downstream${NBSP}SNR${NBSP}#${count}${NBSP}(min/avg/max/cur)[dB]\:\t\t \
						GPRINT:rxsn$count:MIN:%4.1lf\t/ \
						GPRINT:rxsn$count:AVERAGE:%4.1lf\t/ \
						GPRINT:rxsn$count:MAX:%4.1lf\t/ \
						GPRINT:rxsn$count:LAST:%4.1lf\n "
					GPRINT_RXDB="$GPRINT_RXDB \
						LINE3:rxdb1$COLOR_DB:Downstream${NBSP}SIG${NBSP}#${count}${NBSP}(min/avg/max/cur)[dBmV]\:\t\t \
						GPRINT:rxdb$count:MIN:%4.1lf\t/ \
						GPRINT:rxdb$count:AVERAGE:%4.1lf\t/ \
						GPRINT:rxdb$count:MAX:%4.1lf\t/ \
						GPRINT:rxdb$count:LAST:%4.1lf\n "
				done

				$_NICE rrdtool graph                                     \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                         \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "values"                                \
				$DEFAULT_COLORS                                          \
				$LAZY                                                    \
				-W "Generated on: $DATESTRING"                           \
				                                                         \
				$DS_DEF                                                  \
				$GPRINT_RXSN                                             \
				LINE1:4$GREY:"Downstream SIG Optimum\: 4 dBmV\t\t\t\t  --------------------------------\n" \
				$GPRINT_RXDB                                             \
				LINE:44$GREY:"Upstream SIG Optimum\: 44 dBmV\t\t\t\t  --------------------------------\n" \
				$GPRINT_TXDB                                             \
				$GPRINT_TXFQ                                             \
				                                                         > /dev/null 2>&1
			fi
			;;
		epcA)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				local DS_DEF=''
				local GPRINT=''
				count=0
				while [ $count -lt $RRDSTATS_CISCOEPC_RX ]; do
					let count++
					DS_DEF="$DS_DEF DEF:rxsn$count=$FILE:rxsn$count:LAST"
					COLOR_MOD=$((count%4))
					[ $COLOR_MOD == 1 ] && COLOR_VAR=$GREEN
					[ $COLOR_MOD == 2 ] && COLOR_VAR=$YELLOW
					[ $COLOR_MOD == 3 ] && COLOR_VAR=$RED
					[ $COLOR_MOD == 0 ] && COLOR_VAR=$BLUE
					GPRINT="$GPRINT \
						LINE3:rxsn$count$COLOR_VAR:Downstream${NBSP}SNR${NBSP}#${count}${NBSP}(min/avg/max/cur)[dB]\:\t \
						GPRINT:rxsn$count:MIN:%4.1lf\t/ \
						GPRINT:rxsn$count:AVERAGE:%4.1lf\t/ \
						GPRINT:rxsn$count:MAX:%4.1lf\t/ \
						GPRINT:rxsn$count:LAST:%4.1lf\n "
				done
				$_NICE rrdtool graph                                     \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                         \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "values"                                \
				-Y                                                       \
				$DEFAULT_COLORS                                          \
				$LAZY                                                    \
				-A                                                       \
				-W "Generated on: $DATESTRING"                           \
								                                         \
				$DS_DEF                                                  \
				$GPRINT                                                  \
				                                                         > /dev/null 2>&1
			fi
			;;
		epcB)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				local DS_DEF=''
				local GPRINT=''
				count=0
				while [ $count -lt $RRDSTATS_CISCOEPC_RX ]; do
					let count++
					DS_DEF="$DS_DEF DEF:rxdb$count=$FILE:rxdb$count:LAST"
					COLOR_MOD=$((count%4))
					[ $COLOR_MOD == 1 ] && COLOR_VAR=$LGREEN
					[ $COLOR_MOD == 2 ] && COLOR_VAR=$LYELLOW
					[ $COLOR_MOD == 3 ] && COLOR_VAR=$LRED
					[ $COLOR_MOD == 0 ] && COLOR_VAR=$LBLUE
					GPRINT="$GPRINT \
						LINE3:rxdb$count$COLOR_VAR:Downstream${NBSP}SIG${NBSP}#${count}${NBSP}(min/avg/max/cur)[dBmV]\:\t \
						GPRINT:rxdb$count:MIN:%4.1lf\t/ \
						GPRINT:rxdb$count:AVERAGE:%4.1lf\t/ \
						GPRINT:rxdb$count:MAX:%4.1lf\t/ \
						GPRINT:rxdb$count:LAST:%4.1lf\n "
				done
				$_NICE rrdtool graph                                     \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                         \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "values"                                \
				$DEFAULT_COLORS                                          \
				$LAZY                                                    \
				-W "Generated on: $DATESTRING"                           \
								                                         \
				$DS_DEF                                                  \
				LINE1:4$GREY:"Downstream SIG Optimum\: 4 dBmV\t\t\t   -------------------------------\n" \
				$GPRINT                                                   \
				                                                                       > /dev/null 2>&1
			fi
			;;
		epcC)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				local DS_DEF=''
				local GPRINT_FQ=''
				local GPRINT_DB=''
				count=0
				while [ $count -lt $RRDSTATS_CISCOEPC_TX ]; do
					let count++
					DS_DEF="$DS_DEF \
						DEF:txfq$count=$FILE:txfq$count:LAST \
						DEF:txdb$count=$FILE:txdb$count:LAST"
					COLOR_MOD=$((count%2))
					[ $COLOR_MOD == 1 ] && COLOR_DB=$BLUE    && COLOR_FQ=$RED
					[ $COLOR_MOD == 2 ] && COLOR_DB=$GREEN   && COLOR_FQ=$YELLOW
					[ $COLOR_MOD == 3 ] && COLOR_DB=$LGREEN  && COLOR_FQ=$LYELLOW
					[ $COLOR_MOD == 0 ] && COLOR_DB=$LBLUE   && COLOR_FQ=$LRED
					GPRINT_DB="$GPRINT_DB \
						LINE3:txdb$count$COLOR_DB:Upstream${NBSP}SIG${NBSP}#${count}${NBSP}(min/avg/max/cur)[dBmV]\:\t\t \
						GPRINT:txdb$count:MIN:%4.1lf\t/ \
						GPRINT:txdb$count:AVERAGE:%4.1lf\t/ \
						GPRINT:txdb$count:MAX:%4.1lf\t/ \
						GPRINT:txdb$count:LAST:%4.1lf\n "
					GPRINT_FQ="$GPRINT_FQ \
						LINE3:txfq$count$COLOR_FQ:Upstream${NBSP}Frequency${NBSP}#${count}${NBSP}(min/avg/max/cur)[MHz]\:\t \
						GPRINT:txfq$count:MIN:%4.1lf\t/ \
						GPRINT:txfq$count:AVERAGE:%4.1lf\t/ \
						GPRINT:txfq$count:MAX:%4.1lf\t/ \
						GPRINT:txfq$count:LAST:%4.1lf\n "
				done

				$_NICE rrdtool graph                                     \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                         \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "values"                                \
				$DEFAULT_COLORS                                          \
				$LAZY                                                    \
				-Y                                                       \
				-W "Generated on: $DATESTRING"                           \
				                                                         \
				$DS_DEF                                                  \
				$GPRINT_FQ                                               \
				LINE:44$GREY:"Upstream SIG Optimum\: 44 dBmV\t\t\t\t  --------------------------------\n" \
				$GPRINT_DB                                               \
				                                                         > /dev/null 2>&1
			fi
			;;
		epc1)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                   \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                       \
				--title "$TITLE"                                       \
				--start now-$PERIODE                                   \
				--width $WIDTH --height $HEIGHT                        \
				--vertical-label "hours"                               \
				$DEFAULT_COLORS                                        \
				-l 0 $LAZY                                             \
				-W "Generated on: $DATESTRING"                         \
				                                                       \
				DEF:up=$FILE:up:LAST                                   \
				                                                       \
				AREA:up$YELLOW:"System Uptime (avg/max/cur)[hours]\: " \
				GPRINT:up:AVERAGE:"%3.2lf /"                           \
				GPRINT:up:MAX:"%3.2lf /"                               \
				GPRINT:up:LAST:"%3.2lf\n"                              > /dev/null
			fi
			;;
		epc2)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				local DS_DEF=''
				local GPRINT=''
				count=0
				while [ $count -lt $RRDSTATS_CISCOEPC_RX ]; do
					let count++
					DS_DEF="$DS_DEF DEF:rxfq$count=$FILE:rxfq$count:LAST"
					COLOR_MOD=$((count%4))
					[ $COLOR_MOD == 1 ] && COLOR_VAR=$GREEN
					[ $COLOR_MOD == 2 ] && COLOR_VAR=$YELLOW
					[ $COLOR_MOD == 3 ] && COLOR_VAR=$RED
					[ $COLOR_MOD == 0 ] && COLOR_VAR=$BLUE
					GPRINT="$GPRINT \
						LINE3:rxfq$count$COLOR_VAR:Downstream${NBSP}Frequency${NBSP}#${count}${NBSP}(min/avg/max/cur)[MHz]\:\t\
						GPRINT:rxfq$count:MIN:%3.0lf\t/ \
						GPRINT:rxfq$count:AVERAGE:%3.0lf\t/ \
						GPRINT:rxfq$count:MAX:%3.0lf\t/ \
						GPRINT:rxfq$count:LAST:%3.0lf\n "
				done
				$_NICE rrdtool graph                                                   \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                                       \
				--title "$TITLE"                                                       \
				--start now-$PERIODE                                                   \
				--width $WIDTH --height $HEIGHT                                        \
				--vertical-label "MHz"                                                 \
				$DEFAULT_COLORS                                                        \
				$LAZY                                                                  \
				-W "Generated on: $DATESTRING"                                         \
								                                                       \
				$DS_DEF                                                                \
				$GPRINT                                                                \
				                                                                       > /dev/null 2>&1
			fi
			;;
		thg0)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                     \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                         \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "values"                                \
				$DEFAULT_COLORS                                          \
				$LAZY                                                    \
				-W "Generated on: $DATESTRING"                           \
				                                                         \
				DEF:rx=$FILE:rx:LAST                                     \
				DEF:sn=$FILE:sn:LAST                                     \
				DEF:tx=$FILE:tx:LAST                                     \
				DEF:ip=$FILE:ip:LAST                                     \
				                                                         \
				LINE3:tx$GREEN:"Upstream    (min/avg/max/cur)[dBmV]\: "  \
				GPRINT:tx:MIN:" %5.1lf%s"                                \
				GPRINT:tx:AVERAGE:"\t%5.1lf%s"                           \
				GPRINT:tx:MAX:"\t%5.1lf%s"                               \
				GPRINT:tx:LAST:"\t%5.1lf%s\n"                            \
				                                                         \
				LINE3:sn$YELLOW:"S-N Ratio   (min/avg/max/cur)[dB]\:   " \
				GPRINT:sn:MIN:" %3.0lf%s  "                              \
				GPRINT:sn:AVERAGE:"\t%3.0lf%s  "                         \
				GPRINT:sn:MAX:"\t%3.0lf%s  "                             \
				GPRINT:sn:LAST:"\t%3.0lf%s  \n"                          \
				                                                         \
				LINE3:rx$RED:"Downstream  (min/avg/max/cur)[dBmV]\: "    \
				GPRINT:rx:MIN:" %5.1lf%s"                                \
				GPRINT:rx:AVERAGE:"\t%5.1lf%s"                           \
				GPRINT:rx:MAX:"\t%5.1lf%s"                               \
				GPRINT:rx:LAST:"\t%5.1lf%s\n"                            \
				                                                         \
				LINE3:ip$BLUE:"Computers   (min/avg/max/cur)[count]\:"   \
				GPRINT:ip:MIN:" %3.0lf%s  "                              \
				GPRINT:ip:AVERAGE:"\t%3.0lf%s  "                         \
				GPRINT:ip:MAX:"\t%3.0lf%s  "                             \
				GPRINT:ip:LAST:"\t%3.0lf%s  \n"                          > /dev/null
			fi
			;;
		thg1)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                   \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                       \
				--title "$TITLE"                                       \
				--start now-$PERIODE                                   \
				--width $WIDTH --height $HEIGHT                        \
				--vertical-label "hours"                               \
				$DEFAULT_COLORS                                        \
				-l 0 $LAZY                                             \
				-W "Generated on: $DATESTRING"                         \
				                                                       \
				DEF:up=$FILE:up:LAST                                   \
				                                                       \
				AREA:up$YELLOW:"System Uptime (avg/max/cur)[hours]\: " \
				GPRINT:up:AVERAGE:"%3.2lf /"                           \
				GPRINT:up:MAX:"%3.2lf /"                               \
				GPRINT:up:LAST:"%3.2lf\n"                              > /dev/null
			fi
			;;
		thg2)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                    \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                        \
				--title "$TITLE"                                        \
				--start now-$PERIODE                                    \
				--width $WIDTH --height $HEIGHT                         \
				--vertical-label "MHz"                                  \
				$DEFAULT_COLORS                                         \
				$LAZY                                                   \
				-W "Generated on: $DATESTRING"                          \
				                                                        \
				DEF:if=$FILE:if:LAST                                    \
				                                                        \
				LINE3:if$GREEN:"Downstream Frequency (min/avg/max/cur)[MHz]\: " \
				GPRINT:if:MIN:"%3.0lf /"                                \
				GPRINT:if:AVERAGE:"%3.0lf /"                            \
				GPRINT:if:MAX:"%3.0lf /"                                \
				GPRINT:if:LAST:"%3.0lf\n"                               > /dev/null
			fi
			;;
		thg3)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                      \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                          \
				--title "$TITLE"                                          \
				--start now-$PERIODE                                      \
				--width $WIDTH --height $HEIGHT                           \
				--vertical-label "ID"                                     \
				$DEFAULT_COLORS                                           \
				-l 0 -u 5 $LAZY                                           \
				-W "Generated on: $DATESTRING"                            \
				                                                          \
				DEF:uc=$FILE:uc:LAST                                      \
				                                                          \
				LINE3:uc$BLUE:"Upstream Channel (min/avg/max/cur)[ID]\: " \
				GPRINT:uc:MIN:"%3.0lf   /"                                \
				GPRINT:uc:AVERAGE:"%3.0lf   /"                            \
				GPRINT:uc:MAX:"%3.0lf   /"                                \
				GPRINT:uc:LAST:"%3.0lf\n"                                 > /dev/null
			fi
			;;
		arris0)
			FILE=$RRDSTATS_RRDDATA/arris_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                     \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                         \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "values"                                \
				$DEFAULT_COLORS                                          \
				$LAZY                                                    \
				-W "Generated on: $DATESTRING"                           \
				                                                         \
				DEF:rx=$FILE:rx:LAST                                     \
				DEF:sn=$FILE:sn:LAST                                     \
				DEF:tx=$FILE:tx:LAST                                     \
				DEF:ip=$FILE:ip:LAST                                     \
				                                                         \
				LINE3:tx$GREEN:"Upstream   (min/avg/max/cur)[dBmV]\:"    \
				GPRINT:tx:MIN:"%3.0lf /"                                 \
				GPRINT:tx:AVERAGE:"%3.0lf /"                             \
				GPRINT:tx:MAX:"%3.0lf /"                                 \
				GPRINT:tx:LAST:"%3.0lf\n"                                \
				                                                         \
				LINE3:sn$YELLOW:"S-N Ratio    (min/avg/max/cur)[dB]\:"   \
				GPRINT:sn:MIN:"%3.0lf /"                                 \
				GPRINT:sn:AVERAGE:"%3.0lf /"                             \
				GPRINT:sn:MAX:"%3.0lf /"                                 \
				GPRINT:sn:LAST:"%3.0lf\n"                                \
				                                                         \
				LINE3:rx$RED:"Downstream (min/avg/max/cur)[dBmV]\:"      \
				GPRINT:rx:MIN:"%3.0lf /"                                 \
				GPRINT:rx:AVERAGE:"%3.0lf /"                             \
				GPRINT:rx:MAX:"%3.0lf /"                                 \
				GPRINT:rx:LAST:"%3.0lf\n"                                \
				                                                         \
				LINE3:ip$BLUE:"Computers (min/avg/max/cur)[count]\:"     \
				GPRINT:ip:MIN:"%3.0lf /"                                 \
				GPRINT:ip:AVERAGE:"%3.0lf /"                             \
				GPRINT:ip:MAX:"%3.0lf /"                                 \
				GPRINT:ip:LAST:"%3.0lf\n"                                > /dev/null
			fi
			;;
		arris1)
			FILE=$RRDSTATS_RRDDATA/arris_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                   \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                       \
				--title "$TITLE"                                       \
				--start now-$PERIODE                                   \
				--width $WIDTH --height $HEIGHT                        \
				--vertical-label "hours"                               \
				$DEFAULT_COLORS                                        \
				-l 0 $LAZY                                             \
				-W "Generated on: $DATESTRING"                         \
				                                                       \
				DEF:up=$FILE:up:LAST                                   \
				                                                       \
				AREA:up$YELLOW:"System Uptime (avg/max/cur)[hours]\:"  \
				GPRINT:up:AVERAGE:"%3.2lf /"                           \
				GPRINT:up:MAX:"%3.2lf /"                               \
				GPRINT:up:LAST:"%3.2lf\n"                              > /dev/null
			fi
			;;
		arris2)
			FILE=$RRDSTATS_RRDDATA/arris_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                    \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                        \
				--title "$TITLE"                                        \
				--start now-$PERIODE                                    \
				--width $WIDTH --height $HEIGHT                         \
				--vertical-label "MHz"                                  \
				$DEFAULT_COLORS                                         \
				$LAZY                                                   \
				-W "Generated on: $DATESTRING"                          \
				                                                        \
				DEF:if=$FILE:if:LAST                                    \
				                                                        \
				LINE3:if$GREEN:"Downstream Freq (min/avg/max/cur)[MHz]\:" \
				GPRINT:if:MIN:"%5.1lf /"                                \
				GPRINT:if:AVERAGE:"%5.1lf /"                            \
				GPRINT:if:MAX:"%5.1lf /"                                \
				GPRINT:if:LAST:"%5.1lf\n"                               > /dev/null
			fi
			;;
		arris3)
			FILE=$RRDSTATS_RRDDATA/arris_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                      \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                          \
				--title "$TITLE"                                          \
				--start now-$PERIODE                                      \
				--width $WIDTH --height $HEIGHT                           \
				--vertical-label "MHz"                                    \
				$DEFAULT_COLORS                                           \
				$LAZY                                                     \
				-W "Generated on: $DATESTRING"                            \
				                                                          \
				DEF:uf=$FILE:uf:LAST                                      \
				                                                          \
				LINE3:uf$BLUE:"Upstream Freq (min/avg/max/cur)[MHz]\:"    \
				GPRINT:uf:MIN:"%5.1lf /"                                  \
				GPRINT:uf:AVERAGE:"%5.1lf /"                              \
				GPRINT:uf:MAX:"%5.1lf /"                                  \
				GPRINT:uf:LAST:"%5.1lf\n"                                 > /dev/null
			fi
			;;
		csl0) #all
			csl_graph 0 $RRDSTATS_CABLESEG_FRQ
			;;
		csl1) #lower
			local cnt=0
			local _VISIBLE_FRQ=''
			for _CURRENT_FRQ in $RRDSTATS_CABLESEG_FRQ; do
				let cnt++
				[ $cnt -le 4 ] && _VISIBLE_FRQ="$_VISIBLE_FRQ $_CURRENT_FRQ"
			done
			[ -n "$_VISIBLE_FRQ" ] && csl_graph 1 $_VISIBLE_FRQ
			;;
		csl2) #upper
			local cnt=0
			local _VISIBLE_FRQ=''
			for _CURRENT_FRQ in $RRDSTATS_CABLESEG_FRQ; do
				let cnt++
				[ $cnt -gt 4 ] && _VISIBLE_FRQ="$_VISIBLE_FRQ $_CURRENT_FRQ"
			done
			[ -n "$_VISIBLE_FRQ" ] && csl_graph 2 $_VISIBLE_FRQ
			;;
		swap)
			FILE=$RRDSTATS_RRDDATA/mem_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                              \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                                  \
				--title "$TITLE"                                                  \
				--start -1-$PERIODE -l 0 -u 100 -r                                \
				--width $WIDTH --height $HEIGHT	$LAZY                             \
				--vertical-label "Swap usage [%]"                                 \
				$DEFAULT_COLORS                                                   \
				-W "Generated on: $DATESTRING"                                    \
				                                                                  \
				DEF:total=$FILE:swaptotal:AVERAGE                                 \
				DEF:free=$FILE:swapfree:AVERAGE                                   \
				CDEF:used=total,free,-                                            \
				CDEF:usedpct=100,used,total,/,*                                   \
				CDEF:freepct=100,free,total,/,*                                   \
				                                                                  \
				AREA:usedpct#0000FF:"Used swap     (min/avg/max/cur)\:    "       \
				GPRINT:usedpct:MIN:"%5.1lf%% /"                                   \
				GPRINT:usedpct:AVERAGE:"%5.1lf%% /"                               \
				GPRINT:usedpct:MAX:"%5.1lf%% /"                                   \
				GPRINT:usedpct:LAST:"%5.1lf%%\n"                                  \
				                                                                  \
				AREA:freepct#00FF00:"Free swap     (min/avg/max/cur)\:    ":STACK \
				GPRINT:freepct:MIN:"%5.1lf%% /"                                   \
				GPRINT:freepct:AVERAGE:"%5.1lf%% /"                               \
				GPRINT:freepct:MAX:"%5.1lf%% /"                                   \
				GPRINT:freepct:LAST:"%5.1lf%%\n"                                  > /dev/null
			fi
			;;
		diskio1|diskio2|diskio3|diskio4)
			case $1 in
				diskio1)
					DISK=$RRDSTATS_DISK_DEV1
					LG=$RRDSTATS_DISK_LOGARITHM1
					MX=$RRDSTATS_MAX_DISK_GRAPH1
					;;
				diskio2)
					DISK=$RRDSTATS_DISK_DEV2
					LG=$RRDSTATS_DISK_LOGARITHM2
					MX=$RRDSTATS_MAX_DISK_GRAPH2
					;;
				diskio3)
					DISK=$RRDSTATS_DISK_DEV3
					LG=$RRDSTATS_DISK_LOGARITHM3
					MX=$RRDSTATS_MAX_DISK_GRAPH3
					;;
				diskio4)
					DISK=$RRDSTATS_DISK_DEV4
					LG=$RRDSTATS_DISK_LOGARITHM4
					MX=$RRDSTATS_MAX_DISK_GRAPH4
					;;
			esac

			if [ "$LG" = "yes" ]; then
				LOGARITHMIC=" -o "
			else
				LOGARITHMIC=" -l 0 "
			fi

			if [ -z "$MX" -o "$MX" -eq 0 ]; then
				MAXIMALBW=""
			else
				let MAXIMALBW=$MX*1000*1000
				MAXIMALBW=" -r -u $MAXIMALBW "
			fi

			FILE=$RRDSTATS_RRDDATA/$1_$RRDSTATS_INTERVAL-$DISK.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                           \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                               \
				--title "$TITLE"                                               \
				--start -1-$PERIODE $LOGARITHMIC $LAZY $MAXIMALBW              \
				--width $WIDTH --height $HEIGHT                                \
				--vertical-label "bytes/s"                                     \
				$DEFAULT_COLORS                                                \
				--units=si                                                     \
				-W "Generated on: $DATESTRING"                                 \
				                                                               \
				DEF:read=$FILE:read:AVERAGE                                    \
				DEF:write=$FILE:write:AVERAGE                                  \
				                                                               \
				AREA:read$GREEN:"Read        (min/avg/max/cur)[bytes/s]\:"     \
				GPRINT:read:MIN:"%3.0lf%s /"                                   \
				GPRINT:read:AVERAGE:"%3.0lf%s /"                               \
				GPRINT:read:MAX:"%3.0lf%s /"                                   \
				GPRINT:read:LAST:"%3.0lf%s\n"                                  \
				                                                               \
				AREA:write#0000FF80:"Write       (min/avg/max/cur)[bytes/s]\:" \
				GPRINT:write:MIN:"%3.0lf%s /"                                  \
				GPRINT:write:AVERAGE:"%3.0lf%s /"                              \
				GPRINT:write:MAX:"%3.0lf%s /"                                  \
				GPRINT:write:LAST:"%3.0lf%s\n"                                 > /dev/null
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

			FILE=$RRDSTATS_RRDDATA/$1_$RRDSTATS_INTERVAL-$(echo $IF | sed 's/\:/_/g').rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                         \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                             \
				--title "$TITLE"                                             \
				--start -1-$PERIODE $LOGARITHMIC $LAZY $MAXIMALBW            \
				--width $WIDTH --height $HEIGHT                              \
				--vertical-label "bytes/s"                                   \
				$DEFAULT_COLORS                                              \
				--units=si                                                   \
				-W "Generated on: $DATESTRING"                               \
				                                                             \
				DEF:in=$FILE:$NET_RX:AVERAGE                                 \
				DEF:out=$FILE:$NET_TX:AVERAGE                                \
				                                                             \
				AREA:in$GREEN:"Incoming    (min/avg/max/cur)[bytes/s]\:"     \
				GPRINT:in:MIN:"%3.0lf%s /"                                   \
				GPRINT:in:AVERAGE:"%3.0lf%s /"                               \
				GPRINT:in:MAX:"%3.0lf%s /"                                   \
				GPRINT:in:LAST:"%3.0lf%s\n"                                  \
				                                                             \
				AREA:out#0000FF80:"Outgoing    (min/avg/max/cur)[bytes/s]\:" \
				GPRINT:out:MIN:"%3.0lf%s /"                                  \
				GPRINT:out:AVERAGE:"%3.0lf%s /"                              \
				GPRINT:out:MAX:"%3.0lf%s /"                                  \
				GPRINT:out:LAST:"%3.0lf%s"                                   > /dev/null
			fi
			;;

		one)
			_SENSOR_GEN=""
			_SENSOR_CUR=0
			[ "$RRDSTATS_DIGITEMP_C" = yes ] && _SENSOR_UOM=Celsius || _SENSOR_UOM=Fahrenheit
			[ -n "$RRDSTATS_DIGITEMP_L" -o -n "$RRDSTATS_DIGITEMP_U" ] && _SENSOR_LOW="-r "
			[ -n "$RRDSTATS_DIGITEMP_L" ] && _SENSOR_LOW="$_SENSOR_LOW -l $RRDSTATS_DIGITEMP_L"
			[ -n "$RRDSTATS_DIGITEMP_U" ] && _SENSOR_LOW="$_SENSOR_LOW -u $RRDSTATS_DIGITEMP_U"

			if [ $# -ge 5 ]; then
				_SENSOR_ALI=$(grep -vE "^#|^ |^$|^//" /tmp/flash/rrdstats/digitemp.group | tr -s " " | cut -d" " -f1-2 | grep $5$ | cut -d " " -f1)
				_SENSOR_HEX=$(grep -vE "^#|^ |^$|^//" /tmp/flash/rrdstats/digitemp.alias | tr -s " " | cut -d" " -f 1,3 | grep -E "$(echo $_SENSOR_ALI | sed 's/ /\$|/g')$" | cut -d " " -f1)
			else
				_SENSOR_HEX=$(grep "^ROM " /tmp/flash/rrdstats/digitemp.conf 2>/dev/null | sed 's/^ROM .//g;s/ 0x//g')
			fi

			for _CURRENT_HEX in $_SENSOR_HEX; do
				FILE=$RRDSTATS_RRDDATA/one_${RRDSTATS_INTERVAL}-${_CURRENT_HEX}_${_SENSOR_UOM:0:1}.rrd
				if [ -e $FILE ]; then
					_ALIAS=$(grep ^$_CURRENT_HEX /tmp/flash/rrdstats/digitemp.alias | tr -s " " | cut -d " " -f3)
					[ -z "$_ALIAS" ] && _ALIAS=$_CURRENT_HEX
					_COLOR=$(grep ^$_CURRENT_HEX /tmp/flash/rrdstats/digitemp.alias | tr -s " " | cut -d " " -f2)
					[ -z "$_COLOR" ] && _COLOR="#999999"
					_SENSOR_GEN=" $_SENSOR_GEN \
					 DEF:temp$_SENSOR_CUR=$FILE:temp:AVERAGE \
					 LINE3:temp$_SENSOR_CUR$_COLOR:$_ALIAS(min/avg/max/cur)[$(echo -ne '\260')${_SENSOR_UOM:0:1}] \
					 GPRINT:temp$_SENSOR_CUR:MIN:\t%8.3lf \
					 GPRINT:temp$_SENSOR_CUR:AVERAGE:%8.3lf \
					 GPRINT:temp$_SENSOR_CUR:MAX:%8.3lf \
					 GPRINT:temp$_SENSOR_CUR:LAST:\t%8.3lf\n "
				fi
				let _SENSOR_CUR=_SENSOR_CUR+1
			done
			if [ -n "$_SENSOR_GEN" ]; then
				$_NICE rrdtool graph                 \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png     \
				--title "$TITLE"                     \
				--start now-$PERIODE                 \
				--width $WIDTH --height $HEIGHT      \
				--vertical-label "Grad $_SENSOR_UOM" \
				$DEFAULT_COLORS                      \
				--slope-mode HRULE:0#000000          \
				$LAZY $_SENSOR_LOW                   \
				-W "Generated on: $DATESTRING"       \
				$_SENSOR_GEN                         > /dev/null
			fi
			;;
		*)
			echo "unknown graph"
			;;
	esac
	return 1
}

csl_graph() {
	local _CURRENT_PAGE=$1
	shift
	local _VISIBLE_FRQ="$*"
	local STACK=''
	local DS_DEF=''
	local GPRINT=''
	local FRQ_COUNT=$(echo $_VISIBLE_FRQ | wc -w)
	local RPN_O=''
	local RPN_MIN=''
	local RPN_AVG=''
	local RPN_MAX=''
	count=0

	for _CURRENT_FRQ in $_VISIBLE_FRQ; do
		FILE=$RRDSTATS_RRDDATA/csl_${RRDSTATS_INTERVAL}-${_CURRENT_FRQ}000000.rrd
		if [ -e $FILE ]; then
			let count++
			DS_DEF="$DS_DEF DEF:loadMIN$count=$FILE:load:MIN"
			DS_DEF="$DS_DEF DEF:loadAVG$count=$FILE:load:AVERAGE"
			DS_DEF="$DS_DEF DEF:loadMAX$count=$FILE:load:MAX"

			if [ -n "$RPC_MIN$RPN_AVG$RPN_MAX" ]; then
				RPN_O="${RPN_O},+"
				RPN_MIN="${RPN_MIN},"
				RPN_AVG="${RPN_AVG},"
				RPN_MAX="${RPN_MAX},"
			fi
			RPN_MIN="${RPN_MIN}loadMIN$count"
			RPN_AVG="${RPN_AVG}loadAVG$count"
			RPN_MAX="${RPN_MAX}loadMAX$count"

			MULTIP=0
			[ $_CURRENT_PAGE -ne 0 ] && MULTIP=$(($_CURRENT_PAGE-1))
			COLOR_MOD=$(($count+$MULTIP*$FRQ_COUNT % $FRQ_COUNT+$MULTIP*$FRQ_COUNT))
			[ $COLOR_MOD == 1 ] && COLOR_VAR=#fffc00
			[ $COLOR_MOD == 2 ] && COLOR_VAR=#ffc600
			[ $COLOR_MOD == 3 ] && COLOR_VAR=#ffa200
			[ $COLOR_MOD == 4 ] && COLOR_VAR=#ff6c00
			[ $COLOR_MOD == 5 ] && COLOR_VAR=#00c6ff
			[ $COLOR_MOD == 6 ] && COLOR_VAR=#0090ff
			[ $COLOR_MOD == 7 ] && COLOR_VAR=#0066ff
			[ $COLOR_MOD == 8 ] && COLOR_VAR=#0042ff

			GPRINT="$GPRINT \
			AREA:loadAVG$count$COLOR_VAR:$_CURRENT_FRQ${NBSP}MHz${NBSP}(min/avg/max/cur)${NBSP}[MBit/s]\:\t$STACK \
			GPRINT:loadMIN$count:MIN:%4.1lf\t/ \
			GPRINT:loadAVG$count:AVERAGE:%4.1lf\t/ \
			GPRINT:loadMAX$count:MAX:%4.1lf\t/ \
			GPRINT:loadAVG$count:LAST:%4.1lf\n "
			[ -z "$STACK" ] && STACK=":STACK"
		fi
	done
	if [ -n "$DS_DEF" ]; then

		MAXSPEEDC=$(awk "BEGIN{print $FRQ_COUNT*55.62}")
		MAXSPEED="0"
		GPRINT="${GPRINT} COMMENT:${NBSP}${NBSP}Bandwidth${NBSP}available\:${NBSP}$MAXSPEEDC${NBSP}MBit/s\t${NBSP}---------------------------------\n"
		if [ "$_CURRENT_PAGE" == "0" ]; then
			[ "$RRDSTATS_CABLESEG_MAXBW" == "yes" ] && MAXSPEED="1"
		else
			[ "$RRDSTATS_CABLESEG_MAXBWSUB" == "yes" ] && MAXSPEED="1"
		fi
		if [ "$MAXSPEED" == "1" ]; then
			GPRINT="${GPRINT} LINE2:$MAXSPEEDC$GREY"
			local MAXSPEEDP="-u $MAXSPEEDC"
			#local TOPVALUE="VDEF:top=rpn_AVG,MAXIMUM LINE1:top#FF0000"
		fi

		OVERALL=" \
		CDEF:rpn_MIN=$RPN_MIN$RPN_O \
		CDEF:rpn_AVG=$RPN_AVG$RPN_O \
		CDEF:rpn_MAX=$RPN_MAX$RPN_O \
		LINE1:rpn_MAX$BLACK \
		COMMENT:${NBSP}${NBSP}Summary${NBSP}(min/avg/max/cur)${NBSP}[MBit/s]\:\t \
		GPRINT:rpn_MIN:MIN:%4.1lf\t/ \
		GPRINT:rpn_AVG:AVERAGE:%4.1lf\t/ \
		GPRINT:rpn_MAX:MAX:%4.1lf\t/ \
		GPRINT:rpn_AVG:LAST:%4.1lf\n "
		#LINE2:rpn_MAX$GREY
		#LINE2:rpn_MIN$GREEN

		$_NICE rrdtool graph                                     \
		$RRDSTATS_RRDTEMP/$IMAGENAME.png                         \
		--title "$TITLE"                                         \
		--start now-$PERIODE -l 0 $MAXSPEEDP -r                  \
		--width $WIDTH --height $HEIGHT                          \
		--vertical-label "MBit/s"                                \
		-Y                                                       \
		$DEFAULT_COLORS                                          \
		$LAZY                                                    \
		-A                                                       \
		-W "Generated on: $DATESTRING"                           \
		                                                         \
		$DS_DEF $GPRINT $OVERALL $TOPVALUE                       \
		                                                         > /dev/null 2>&1
	fi
}

set_lazy() {
	LAZY=" "
	[ -z "$NOTLAZY" -a "$1" = "no" ] && LAZY=" -z "
}

set_period() {
	periodA=$(echo $1 | sed 's/[0-9]\+h$/hour/g;s/[0-9]\+d$/day/g;s/[0-9]\+w$/week/g;s/[0-9]\+m$/month/g;s/[0-9]\+y$/year/g')
	period0=$(echo $1 | sed 's/[a-zA-Z]//g')
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
	GROUP=$4
	[ $# -ge 4 ] && GROUP_URL="&group=$4"
	sec_begin "$FNAME"
	generate_graph "$SNAME" "$CURRENT_PERIOD" "$SNAME" "" $GROUP
	echo "<center><a href=\"$SCRIPT_NAME?graph=$SNAME$GROUP_URL\" class=\"image\">"
	echo "<img src=\"/statpix/$SNAME$GROUP.png$NOCACHE\" alt=\"$FNAME stats for last $LAPSE\" border=\"0\" />"
	echo "</a></center>"
	sec_end
}

graphit() {
	graph=$1
	#graph=$(cgi_param graph | tr -d .)
	case $graph in
		cpu|mem|swap|upt|temp|thg0|thg1|thg2|thg3|epc0|epcA|epcB|epcC|epc1|epc2|arris0|arris1|arris2|arris3|csl0|csl1|csl2|diskio1|diskio2|diskio3|diskio4|if1|if2|if3|if4|one)
			set_lazy "$RRDSTATS_NOTLAZYS"
			#GROUP_PERIOD=$(cgi_param group | tr -d .)
			if [ -z "$GROUP_PERIOD" ]; then
				heading=$(echo $graph | sed "s/^upt$/Uptime/;s/^temp$/Temperature/;s/^cpu$/Processor/;s/^mem$/Memory/;s/^swap$/Swapspace/;\
				  s/^thg0$/Thomson THG - basic/;s/^thg1$/Thomson THG - System Uptime/;s/^thg2/Thomson THG - Downstream Frequency/;s/^thg3$/Thomson THG - Upstream Channel/;\
				  s/^epc0$/Cisco EPC - Overview/;\
				  s/^epcA$/Cisco EPC - Downstream Signal-Noise-Ratio/;s/^epcB$/Cisco EPC - Downstream Signal-Power-Level/;s/^epcC/Cisco EPC - Upstream Signal-Power-Level \& Frequency/;\
				  s/^epc1$/Cisco EPC - System Uptime/;s/^epc2/Cisco EPC - Downstream Frequency/;\
				  s/^csl0$/Cable segment load/;s/^csl1$/Cable segment load - lower frequencies/;s/^csl2$/Cable segment load - upper frequencies/;\
				  s/^arris0$/Arris TM - basic/;s/^arris1$/Arris TM - System Uptime/;s/^arris2/Arris TM - Downstream Frequency/;s/^arris3$/Arris TM - Upstream Frequency/;\
				  s/^diskio1$/$RRDSTATS_DISK_NAME1/;s/^diskio2$/$RRDSTATS_DISK_NAME2/;s/^diskio3$/$RRDSTATS_DISK_NAME3/;s/^diskio4$/$RRDSTATS_DISK_NAME4/;\
				  s/^if1$/$RRDSTATS_NICE_NAME1/;s/^if2$/$RRDSTATS_NICE_NAME2/;s/^if3$/$RRDSTATS_NICE_NAME3/;s/^if4$/$RRDSTATS_NICE_NAME4/;s/^one$/DigiTemp/")
			else
				heading="$GROUP_PERIOD"
			fi
			echo "<center><font size=+1><br><b>$heading stats</b></font></center>"

			if [ "$(echo "$graph" | sed 's/^thg./yes/')" = yes -a "$RRDSTATS_THOMSON_ADV" = yes ]; then
				echo "<br><center> \
				<input type=\"button\" value=\"THG basics\" onclick=\"window.location=('$SCRIPT_NAME?graph=thg0')\" /> \
				<input type=\"button\" value=\"System Uptime\" onclick=\"window.location=('$SCRIPT_NAME?graph=thg1')\" /> \
				<input type=\"button\" value=\"Downstream Frequency\" onclick=\"window.location=('$SCRIPT_NAME?graph=thg2')\" /> \
				<input type=\"button\" value=\"Upstream Channel\" onclick=\"window.location=('$SCRIPT_NAME?graph=thg3')\" /> \
				</center>"
			fi
			if [ "$(echo "$graph" | sed 's/^epc./yes/')" = yes ]; then
				echo "<br><center>"
				echo "<input type=\"button\" value=\"Overview\" onclick=\"window.location=('$SCRIPT_NAME?graph=epc0')\" />"
				echo "<input type=\"button\" value=\"Downstream FRQ\" onclick=\"window.location=('$SCRIPT_NAME?graph=epc2')\" />"
				if [ "$RRDSTATS_CISCOEPC_DETAILS" == "yes" ]; then
					echo "<input type=\"button\" value=\"Downstream SNR\" onclick=\"window.location=('$SCRIPT_NAME?graph=epcA')\" />"
					echo "<input type=\"button\" value=\"Downstream SIG\" onclick=\"window.location=('$SCRIPT_NAME?graph=epcB')\" />"
					echo "<input type=\"button\" value=\"Upstream SIG & FRQ\" onclick=\"window.location=('$SCRIPT_NAME?graph=epcC')\" />"
				fi
				[ "$RRDSTATS_CISCOEPC_UP" == "yes" ] && echo "<input type=\"button\" value=\"System Uptime\" onclick=\"window.location=('$SCRIPT_NAME?graph=epc1')\" />"
				echo "</center>"
			fi
			if [ "$(echo "$graph" | sed 's/^arris./yes/')" = yes -a "$RRDSTATS_ARRISTM_ADV" = yes ]; then
				echo "<br><center> \
				<input type=\"button\" value=\"Arris TM basics\" onclick=\"window.location=('$SCRIPT_NAME?graph=arris0')\" /> \
				<input type=\"button\" value=\"System Uptime\" onclick=\"window.location=('$SCRIPT_NAME?graph=arris1')\" /> \
				<input type=\"button\" value=\"Downstream Frequency\" onclick=\"window.location=('$SCRIPT_NAME?graph=arris2')\" /> \
				<input type=\"button\" value=\"Upstream Frequency\" onclick=\"window.location=('$SCRIPT_NAME?graph=arris3')\" /> \
				</center>"
			fi
			if [ "$(echo "$graph" | sed 's/^csl./yes/')" = yes ]; then
				echo "<br><center> \
				<input type=\"button\" value=\"lower frequencies\" onclick=\"window.location=('$SCRIPT_NAME?graph=csl1')\" /> \
				&nbsp; \
				<input type=\"button\" value=\"all frequencies\" onclick=\"window.location=('$SCRIPT_NAME?graph=csl0')\" /> \
				&nbsp; \
				<input type=\"button\" value=\"upper frequencies\" onclick=\"window.location=('$SCRIPT_NAME?graph=csl2')\" /> \
				</center>"
			fi


			[ -n "$PERIOD_ARG" ] && CURRENT_PERIOD="$PERIOD_ARG" || CURRENT_PERIOD="$RRDSTATS_PERIODSSUB"
			for period in $CURRENT_PERIOD; do
				set_period $period
				sec_begin "last $periodnn"
				generate_graph "$graph" "$periodG" "$graph-$period" "" $GROUP_PERIOD
				echo "<center><a href=\"$SCRIPT_NAME\" class=\"image\">"
				echo "<img src=\"/statpix/$graph-$period$GROUP_PERIOD.png$NOCACHE\" alt=\"$heading stats for last $periodnn\" border=\"0\" />"
				echo "</a></center>"
				sec_end
			done
			[ -n "$HTTP_REFERER" ] && backdest="history.go(-1)" || backdest="window.location.href='$SCRIPT_NAME'"
			echo "<br><center><input type=\"button\" value=\"Back\" onclick=\"javascript:$backdest\" /></center>"
			;;
		*)
			set_lazy "$RRDSTATS_NOTLAZYM"
			[ -n "$PERIOD_ARG" ] && CURRENT_PERIOD="$PERIOD_ARG" || CURRENT_PERIOD="$RRDSTATS_PERIODMAIN"
			set_period "$CURRENT_PERIOD"
			echo "<center><font size=+1><br><b>Stats for last $periodnn</b></font></center>"
			case $RRD_DISPLAY_TYPE in
				rrddt)
					ALL_GROUPS=$(grep -vE "^#|^$|^ " /var/tmp/flash/rrdstats/digitemp.group 2>/dev/null | tr -s " " | cut -d " " -f2 | uniq)
					[ -z "$ALL_GROUPS" ] && gen_main "one" "$curgroup" "$periodnn"
					for curgroup in $ALL_GROUPS; do
						gen_main "one" "$curgroup" "$periodnn" "$curgroup"
					done
					;;
				*)
					gen_main "cpu" "Processor" "$periodnn"
					gen_main "mem" "Memory" "$periodnn"
					[ "$(free | grep "Swap:" | awk '{print $2}')" != "0" ] && gen_main "swap" "Swapspace" "$periodnn"
					[ "$RRDSTATS_UPTIME_ENB" = yes ] && gen_main "upt" "Uptime" "$periodnn"
					if [ "$FREETZ_PACKAGE_RRDSTATS_TEMPERATURE_SENSOR" == "y" ]; then
						[ "$RRDSTATS_TEMP_ENB" = yes ] && gen_main "temp" "Temperature" "$periodnn"
					fi
					if [ "$FREETZ_PACKAGE_RRDSTATS_CABLEMODEM" == "y" ]; then
						[ "$RRDSTATS_CABLE_MODEM" = thg ] && gen_main "thg0" "Thomson THG" "$periodnn"
						[ "$RRDSTATS_CABLE_MODEM" = epc ] && gen_main "epc0" "Cisco EPC" "$periodnn"
						[ "$RRDSTATS_CABLE_MODEM" = arris ] && gen_main "arris0" "Arris TM" "$periodnn"
					fi
					if [ "$FREETZ_PACKAGE_RRDSTATS_SEGMENTLOAD" == "y" ]; then
						[ "$RRDSTATS_CABLESEG_ENABLED" = yes ] && gen_main "csl0" "Cable segment load" "$periodnn"
					fi
					if [ "$FREETZ_PACKAGE_RRDSTATS_STORAGE" == "y" ]; then
						[ -n "$RRDSTATS_DISK_DEV1" ] && gen_main "diskio1" "$RRDSTATS_DISK_NAME1" "$periodnn"
						[ -n "$RRDSTATS_DISK_DEV2" ] && gen_main "diskio2" "$RRDSTATS_DISK_NAME2" "$periodnn"
						[ -n "$RRDSTATS_DISK_DEV3" ] && gen_main "diskio3" "$RRDSTATS_DISK_NAME3" "$periodnn"
						[ -n "$RRDSTATS_DISK_DEV4" ] && gen_main "diskio4" "$RRDSTATS_DISK_NAME4" "$periodnn"
					fi
					if [ "$FREETZ_PACKAGE_RRDSTATS_NETWORK" == "y" ]; then
						[ -n "$RRDSTATS_INTERFACE1" ] && gen_main "if1" "$RRDSTATS_NICE_NAME1" "$periodnn"
						[ -n "$RRDSTATS_INTERFACE2" ] && gen_main "if2" "$RRDSTATS_NICE_NAME2" "$periodnn"
						[ -n "$RRDSTATS_INTERFACE3" ] && gen_main "if3" "$RRDSTATS_NICE_NAME3" "$periodnn"
						[ -n "$RRDSTATS_INTERFACE4" ] && gen_main "if4" "$RRDSTATS_NICE_NAME4" "$periodnn"
					fi
					;;
			esac
			;;
	esac
}

for single_graph in $ALL_GRAPHS; do
	graphit $single_graph
done
