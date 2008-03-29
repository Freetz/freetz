#!/bin/sh
if [ ! -r /mod/etc/conf/rrdstats.cfg ]; then
	exit 1
fi
. /mod/etc/conf/rrdstats.cfg

# modified by cuma
# file: memory.sh
# created by ramik 11/02/2008
#
# run awk recipe directly against /proc/meminfo
# awk recipe will concatenate the values with : as separator
# will create /path/memory.rrd on Fritz!Box prior to first use

NAMEPREFIX=memory

if ! [ -e $RRDSTATS_RRDDATA/$NAMEPREFIX.rrd ]; then

	rrdtool create $RRDSTATS_RRDDATA/$NAMEPREFIX.rrd	\
	--step $RRDSTATS_INTERVAL		\
	DS:used:GAUGE:600:0:5000000000		\
	DS:free:GAUGE:600:0:5000000000		\
	DS:buff:GAUGE:600:0:5000000000		\
	DS:cached:GAUGE:600:0:5000000000 	\
	DS:swap:GAUGE:600:0:5000000000		\
	DS:swaptotal:GAUGE:600:0:5000000000 	\
	DS:swapfree:GAUGE:600:0:5000000000 	\
	RRA:AVERAGE:0.5:1:576			\
	RRA:AVERAGE:0.5:6:672			\
	RRA:AVERAGE:0.5:24:732			\
	RRA:AVERAGE:0.5:144:1460
fi

memdata=`awk '
	/^MemTotal:/ 	{total=$2*1024}
	/^MemFree:/	{free=$2*1024}
	/^Buffers:/	{buff=$2*1024}
	/^Cached:/	{cached=$2*1024}
	/^SwapTotal:/	{swaptotal=$2*1024}
	/^SwapFree:/	{swapfree=$2*1024}
	END {
		used=total-(free+buff+cached)
		swap=swaptotal-swapfree
	print "N:" used ":" free ":" buff ":" cached ":" swap ":" swaptotal ":" swapfree}' /proc/meminfo`
rrdtool update \
	$RRDSTATS_RRDDATA/$NAMEPREFIX.rrd \
	--template used:free:buff:cached:swap:swaptotal:swapfree \
	$memdata
# End of file
