#!/bin/sh
if [ ! -r /mod/etc/conf/rrdstats.cfg ]; then
	exit 1
fi
. /mod/etc/conf/rrdstats.cfg

# modified by cuma
# file: wan.sh
# created by ramik 11/02/2008
#
# run awk recipe directly against ifconfig
# awk recipe will concatenate the values with : as separator
# will create /path/*.rrd on Fritz!Box prior to first use

NAMEPREFIX=net_$RRDSTATS_WANINTERFACE

if ! [ -e $RRDSTATS_RRDDATA/$NAMEPREFIX.rrd ]; then

	rrdtool create $RRDSTATS_RRDDATA/$NAMEPREFIX.rrd	\
	--step $RRDSTATS_INTERVAL		\
	DS:in:DERIVE:600:0:12500000		\
	DS:out:DERIVE:600:0:12500000		\
	RRA:AVERAGE:0.5:1:576			\
	RRA:AVERAGE:0.5:6:672			\
	RRA:AVERAGE:0.5:24:732			\
	RRA:AVERAGE:0.5:144:1460
fi

wandata=`/sbin/ifconfig ${RRDSTATS_WANINTERFACE} |grep bytes|awk -F ":" '{print $2 " " $3}'|awk '{print "N:"$1":"$6}'`

rrdtool  update	\
	--template in:out \
	$RRDSTATS_RRDDATA/$NAMEPREFIX.rrd $wandata
# End of file
