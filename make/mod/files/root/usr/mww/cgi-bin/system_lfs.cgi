#!/bin/sh
##############################################################################
# Inspired and code parts from gui_boot_manager script of modfs by PeterPawn #
# https://github.com/PeterPawn/modfs https://github.com/PeterPawn/modfs/blob #
# /2b7afae559c587556b04d0e654221ce2df2a0747/modscripts/gui_boot_manager_v0.4 #
##############################################################################
###                         from gui_boot_manager:                         ###
##############################################################################
#                                                                            #
# GUI Boot Manager extension for AVM's FRITZ!Box routers with "hot flash"    #
# capabilities                                                               #
#                                                                            #
# Copyright (C) 2014-2017 P.Haemmerlein (http://www.yourfritz.de)            #
#                                                                            #
# This program is free software; you can redistribute it and/or              #
# modify it under the terms of the GNU General Public License                # 
# as published by the Free Software Foundation; either version 2             #
# of the License, or (at your option) any later version.                     #
#                                                                            #
# This program is distributed in the hope that it will be useful,            #
# but WITHOUT ANY WARRANTY; without even the implied warranty of             #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
# GNU General Public License under                                           #
# http://www.gnu.org/licenses/gpl-2.0.html                                   #
# for more details.                                                          #
#                                                                            #
# "FRITZ!Box" is a registered word mark and "AVM" is a registered            #
# word and figurative mark of:                                               #
# AVM Computersysteme Vertriebs GmbH, 10559, Berlin, DE.                     #
#                                                                            #
##############################################################################

[ -r /etc/options.cfg ] && . /etc/options.cfg

get_partition_by_name() {
	if [ "$FREETZ_TYPE_CABLE" != "y" ]; then
		name=$2${2:+-}$1
		sed -n -e "s|mtd\([0-9]\{1,2\}\): [0-9a-f]\{8\} [0-9a-f]\{8\} \"${name}\"|\1|p" /proc/mtd
	else
		name="$1${2:+_}${2}_ATOM"
		sed -n -e "s|^${name}=/dev/mmcblk0p\([0-9]\{1,2\}\)\$|\1|p" /proc/avm_partitions
	fi
}

imginfo() {
	DIR=${1:-/}

	VER="$(cat ${DIR}/etc/.version)"
	REV="$(cat ${DIR}/etc/.revision)"
	DAT="$(sed -rn 's!.*FIRMWARE_DATE=!!p' ${DIR}/etc/version | sed 's/\"//g')"
	echo "FritzOS $VER rev$REV ($DAT)"

	if [ -e ${DIR}/etc/.freetz-version ]; then
		SUB="$(cat ${DIR}/etc/.freetz-version)"
		FMD="$(date -d @$(stat -c %Y ${DIR}/etc/.freetz-version) +'%d.%m.%Y %H:%M:%S')"
		echo "Freetz ${SUB##*freetz-} ($FMD)"
	fi

	if [ -e ${DIR}/etc/.modfs_version ]; then
		BLD="$(cat ${DIR}/etc/.modfs_version)"
		MFS="$(date -d @$(stat -c %Y ${DIR}/etc/etc/.modfs_version) +'%d.%m.%Y %H:%M:%S')"
		echo "ModFS $BLD ($MFS)"
	fi
}

NOW="$(date +%s)"
OUTER="/tmp/reserve_$NOW"
INNER="/tmp/wrapper_$NOW"
resmnt() {
	mkdir $OUTER
	[ -d /wrapper ] && fst=yaffs2 || fst=squashfs
	[ "$FREETZ_TYPE_CABLE" != "y" ] && DEV=mtdblock || DEV=mmcblk0p
	mount -t $fst -o ro /dev/$DEV$DEAD $OUTER || mount -o ro /dev/$DV$DEAD $OUTER
	MNT=$OUTER

	if [ -f $OUTER/filesystem_core.squashfs ]; then
		mkdir $INNER
		mount -t squashfs -o ro $OUTER/filesystem_core.squashfs $INNER
		MNT=$INNER
	fi
}
resunm() {
	if [ -d $INNER ]; then
		umount $INNER
		rmdir $INNER
	fi

	umount $OUTER
	rmdir $OUTER
}

NEXT="$(sed -n 's/^linux_fs_start[ \t]*//p' /proc/sys/urlader/environment)"
[ -z "$NEXT" ] && NEXT=0

LIVE="$(get_partition_by_name filesystem)"
DEAD="$(get_partition_by_name filesystem reserved)"

PRIB="$(imginfo /)"
resmnt
SECB="$(imginfo $MNT)"
resunm

[ $LIVE -gt $DEAD ] && LFS=1 || LFS=0
[ "$LFS" != "$NEXT" ] && RUN="$(lang de:"deaktiviert" en:"disabled")" || RUN="$(lang de:"aktiviert" en:"enabled")"
PRIH="$(lang de:"Momentan in" en:"Running at") linux_fs_start=$LFS, $RUN $(lang de:"beim n&auml;chsten Systemstart" en:"on next system start")"

[ $LIVE -gt $DEAD ] && LFS=0 || LFS=1
[ "$LFS" != "$NEXT" ] && RUN="$(lang de:"deaktiviert" en:"disabled")" || RUN="$(lang de:"aktiviert" en:"enabled")"
SECH="$(lang de:"Reserve in" en:"Reserve at") linux_fs_start=$LFS, $RUN $(lang de:"beim n&auml;chsten Systemstart" en:"on next system start")"


cat << EOF | sed -r 's#(Running|Momentan| enabled| aktiviert)#<span class="success">\1</span>#g;s#(Reserve| disabled| deaktiviert)#<span class="failure">\1</span>#g'
<h1>$(lang de:"Vorhandene Firmwareversionen" en:"Available firmware versions")</h1>
<ul><li>$PRIH</li></ul>
<pre>$PRIB</pre>
<ul><li>$SECH</li></ul>
<pre>$SECB</pre>
EOF

stat_button linux_fs_start '$(lang de:"Firmwarepartition wechseln" en:"Toggle firmware partition")'

