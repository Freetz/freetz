#!/bin/sh
if [ ! -r /mod/etc/conf/rrdstats.cfg ]; then
	exit 1
fi
. /mod/etc/conf/rrdstats.cfg

# modified by cuma
# file: memory.sh
# created by ramik 11/02/2008
#
# run awk recipe directly against /proc/stat
# awk recipe will concatenate the values with : as separator
# will create /path/*.rrd on Fritz!Box prior to first use

NAMEPREFIX=cpu

if ! [ -e $RRDSTATS_RRDDATA/$NAMEPREFIX.rrd ]; then

	rrdtool create $RRDSTATS_RRDDATA/$NAMEPREFIX.rrd      \
	--step $RRDSTATS_INTERVAL	 \
	DS:user:COUNTER:600:0:100       \
	DS:nice:COUNTER:600:0:100       \
	DS:syst:COUNTER:600:0:100       \
	DS:wait:COUNTER:600:0:100       \
	DS:idle:COUNTER:600:0:100       \
	RRA:AVERAGE:0.5:1:576		\
	RRA:AVERAGE:0.5:6:672		\
	RRA:AVERAGE:0.5:24:732		\
	RRA:AVERAGE:0.5:144:1460	
fi

cpudata=`grep '^cpu ' /proc/stat | awk '{print "N:"$2":"$3":"$4":"$6+$7":"$5;}'`
rrdtool  update \
	$RRDSTATS_RRDDATA/$NAMEPREFIX.rrd  \
	--template user:nice:syst:wait:idle \
	$cpudata
# End of file
