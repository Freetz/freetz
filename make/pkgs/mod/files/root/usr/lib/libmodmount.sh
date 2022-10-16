#! /bin/sh
. /etc/init.d/loglibrc
[ -r /mod/etc/conf/mod.cfg ] && . /mod/etc/conf/mod.cfg

# returns AVM firmware version as integer (i.e. without dot)
get_avm_firmware_version() {
	# use CONFIG_VERSION if set, /etc/.version otherwise
	local v="${CONFIG_VERSION:-$(cat /etc/.version)}"
	echo "${v/.}"
}

# Log to Syslog & Console
log_freetz() {
	loglib_system "FREETZMOUNT" "$2"
	local c_prefix
	[ "$1" == "err" ] && c_prefix='[FAIL]' || c_prefix='[INFO]'
	echo "$c_prefix $2" >> /var/log/mod_mount.log
}

# modified name generation for automatic mount point
# freetz internal function
#
# $1 - block device name (without /dev/ prefix)
# $2 - partition number
#
find_mnt_name() {
	local mnt_name=""

	local storage_prefix=$(echo -n ${MOD_STOR_PREFIX})                  # trim leading, trailing, and multiple spaces in-between
	storage_prefix=${storage_prefix:-uStor}                             # and ensure it's not empty

	local dev_idx=$(echo -n ${1:2} | tr '[a-j]' '[0-9]')
	local part_idx=$(printf "%X" $2)                                    # partition index in HEX

	if [ "$MOD_STOR_NAMING_SCHEME" == "PARTITION_LABEL" ]; then
		[ "$2" == "0" ] && local mnt_device="/dev/$1" || local mnt_device="/dev/$1$2"
		mnt_name="$(blkid $mnt_device | sed -rn 's!.*LABEL="([^"]*).*!\1!p')"
		mnt_name=$(echo -n $mnt_name)                               # trim leading, trailing, and multiple spaces in-between
	elif [ "$MOD_STOR_NAMING_SCHEME" == "VENDOR_PRODUCT" ]; then
		# a slightly modified version of AVMs nicename from the 6.20 firmware series
		local VENDOR=$(cat /sys/block/$1/device/vendor 2>/dev/null | tr -d ' ' | tr -c "\na-zA-Z0-9" '-')
		local MODEL=$(cat  /sys/block/$1/device/model  2>/dev/null | tr -d ' ' | tr -c "\na-zA-Z0-9" '-')

		mnt_name="${VENDOR}${VENDOR:+-}${MODEL:-${storage_prefix}}" # build "Vendor-Product" prefix, limit it to 30 characters,
		mnt_name="${mnt_name:0:30}-${dev_idx}${part_idx}"           # and add "-<device index><partition index>" suffix
	fi

	if [ -z "$mnt_name" ]; then
		mnt_name="${storage_prefix:0:30}${dev_idx}${part_idx}"
	fi

	echo -n ${mnt_name// /_}                                            # replace all spaces with underscores
}

# mount filesystem according to its type
# freetz internal function
#
# $1 - block device name (including /dev/ prefix, e.g. /dev/sda1)
# $2 - full mount point path (e.g. /var/media/ftp/uStor01)
# $3 (optional) - read/write mode (e.g. rw, rw if omitted)
# $4 (optional) - uid of the mounted files (0 if omitted)
# $5 (optional) - gid of the mounted files (0 if omitted)
#
mount_fs() {
	local dev_node=$1                                                         # device node
	local mnt_path=$2                                                         # mount path
	[ $# -ge 3 ] && local rw_mode=$3 || local rw_mode=rw                      # read/write mode
	[ $# -ge 4 ] && local ftp_uid=$4 || local ftp_uid=0                       # ftp user id
	[ $# -ge 5 ] && local ftp_gid=$5 || local ftp_gid=0                       # ftp group id
	local err_mo=1                                                            # set mount error as default
	local fs_type="$(blkid $dev_node | sed -nr 's!.*TYPE="([^"]*).*!\1!p')"   # fs type detection
	[ -z "$fs_type" ] && local fs_type="unknown"                              # set unknown file system type if detection failed
	case $fs_type in
		vfat)
			mount -t vfat -o $rw_mode,noatime,shortname=winnt,uid=$ftp_uid,gid=$ftp_gid,fmask=0000,dmask=0000 $dev_node $mnt_path
			err_mo=$?
			;;
		ext2|ext3|ext4|reiserfs)
			mount -t $fs_type $dev_node $mnt_path -o noatime,nodiratime,rw,async
			err_mo=$?
			;;
		hfs|hfsplus)
			mount -t $fs_type $dev_node $mnt_path
			err_mo=$?
			;;
		crypto_LUKS)
			err_mo=1
			;;
		ntfs)
			[ -x "$(which ntfs-3g)" ] && { ntfs-3g $dev_node $mnt_path -o force ; err_mo=$? ; } || err_mo=111
			;;
		swap)
			if [ -e /etc/init.d/rc.swap ]; then
				/etc/init.d/rc.swap autostart $dev_node
				err_mo=$((17+$?))
			else
				err_mo=22
			fi
			;;
		*)                                                                # fs type unknown
			mount $dev_node $mnt_path
			err_mo=$?
			;;
	esac
	echo -n "$fs_type"
	return $err_mo
}

# mount function
# used by /etc/hotplug/run_mount
# separated from do_mount since fw 04.89
#
# $1 - proc device, e.g. /proc/bus/usb/001/002 (before 6.25) or just 001/002 (since 6.25)
# $2 - block device name (including /dev/ prefix, e.g. /dev/sda1)
# $3 - partition number
#
do_mount_locked() {
	local mnt_rw=rw
	[ $# -ge 2 ] && local mnt_dev=$2 || return 1
	[ $# -ge 3 ] && local mnt_part_num=$3 || return 1
	local mnt_blk_dev=${mnt_dev##/dev/}
	local mnt_main_dev=${mnt_blk_dev:0:3}
	local mnt_name
	local mnt_path
	local fs_type

	mount | grep -q "$mnt_dev on /var/media/" && return 0                      # device already mounted

	mnt_name=$(find_mnt_name $mnt_main_dev $mnt_part_num)
	mnt_path=$FTPDIR/$mnt_name
	if [ ! -d $mnt_path ]; then
		mkdir -p $mnt_path
	fi

	chmod 755 $FTPDIR                                                          # chmod for ftp top directory
	local old_umask=$(umask)                                                   # store actual umask
	umask 0

	fs_type=$(mount_fs $mnt_dev $mnt_path $mnt_rw $FTPUID $FTPGID)             # FREETZ mount
	local err_fs_mount=$?

	# update device map, do it before notifying other components about changes
	# TODO: it should be enough to do it on successful mount only, i.e. if err_fs_mount==0
	if grep -q $mnt_path /proc/mounts; then
		if [ -f "$1" -o -f "/proc/bus/usb/$1" -o -e "/dev/bus/usb/$1" ]; then
			grep -v "^$1=$2:" $DEVMAP > /var/dev-$$.map
			echo "$1=$2:$mnt_name" >> /var/dev-$$.map
			mv -f /var/dev-$$.map $DEVMAP
		fi
	fi

	umask $old_umask                                                           # restore umask

	if [ $err_fs_mount -eq 0 ]; then
		local rcftpd="/etc/init.d/rc.ftpd"
		local tr069starter="/bin/tr069starter"
		local samba_control="/etc/samba_control"
		local fritznasdb_control="/etc/fritznasdb_control"
		local tammnt="/var/tam/mount"
		local autorun="$mnt_path/autorun.sh"

		eventadd 140 "$mnt_name ($mnt_dev)"
		log_freetz notice "Partition $mnt_name ($mnt_dev) was mounted successfully ($fs_type)"

		if [ -x $rcftpd ]; then                                                                                 # start/enable ftpd
			[ -x "$(which inetdctl)" ] && inetdctl enable ftpd || $rcftpd start
		fi

		# freetz extras
		[ -e /etc/init.d/rc.swap ] && /etc/init.d/rc.swap autostart $mnt_path                                   # swap
		[ "$MOD_STOR_AUTORUNEND" == "yes" -a -x $autorun ] && $autorun &                                        # autorun
		[ -r /mod/etc/external.pkg ] && /etc/init.d/rc.external start $mnt_path &                               # external

		[ -x $tr069starter ] && $tr069starter $mnt_name                                                         # tr069
		[ -x $samba_control ] && $samba_control reconfig                                                        # SAMBA reconfiguration
		[ -p $tammnt ] && echo "m$mnt_path" > $tammnt                                                           # tam

		rm -f /var/media/NEW_LINK && ln -fs $mnt_path /var/media/NEW_LINK                                       # mark last mounted partition

		# notify other components that a new partition has been mounted
		if [ $(get_avm_firmware_version) -lt 557 ]; then                                                        # existence of /sbin/upnpdevd could NOT be used as a criterion (available since 05.50)
			msgsend multid update_usb_infos                                                                 # Fritz!OS < 5.57
		else
			msgsend upnpdevd update_usb_infos                                                               # Fritz!OS >= 5.57
		fi
		[ -e /lib/libmediasrv.so ] && msgsend upnpd plugin force_notify libmediasrv.so new_partition            # mediasrv
		[ -e /lib/libgpmsrv.so   ] && msgsend upnpd plugin force_notify libgpmsrv.so "new_partition:$mnt_path"  # google play music
		[ -x $fritznasdb_control ] && $fritznasdb_control new_partition $mnt_path                               # fritznasdb

		[ -x "$(which led-ctrl)" ] && led-ctrl filesystem_done                                                  # led

		return 0
	fi

	# mount failed
	local mnt_failure=0
	rmdir $mnt_path
	case "$fs_type" in
		"crypto_LUKS")
				eventadd 140 "LUKS ($mnt_dev) detected/erkannt, NOT/NICHT"
				log_freetz notice "LUKS partition $mnt_dev was detected"
			;;
		"ntfs")
			case $err_fs_mount in
				15)                                                           # unclean unmount
					eventadd 144 "$mnt_name ($mnt_dev)"
					log_freetz err "NTFS partition $mnt_name ($mnt_dev) was not cleanly unmounted, please check the filesystem on it"
					;;
				111)                                                          # binary not found
					eventadd 145 "$mnt_name ($mnt_dev)" "ntfs binary not found"
					log_freetz err "NTFS partition $mnt_name ($mnt_dev) was not mounted, ntfs binary not found"
					mnt_failure=1
					;;
				*)                                                            # general error
					eventadd 145 "$mnt_name ($mnt_dev)" $err_fs_mount
					log_freetz err "NTFS partition $mnt_name ($mnt_dev) was not mounted, error $err_fs_mount"
					mnt_failure=1
					;;
			esac
			;;
		"swap")
			case "$err_fs_mount" in
				17)                                                           # fine
					eventadd 140 "SWAP ($mnt_dev)"
					log_freetz notice "SWAP partition $mnt_dev was mounted successfully"
					;;
				19)                                                           # other partition
					eventadd 140 "SWAP ($mnt_dev) NOT/NICHT"
					log_freetz notice "SWAP partition $mnt_dev was not mounted, not the defined swap-partition"
					;;
				20)                                                           # disabled
					eventadd 140 "SWAP ($mnt_dev) NOT/NICHT"
					log_freetz notice "SWAP partition $mnt_dev was not mounted, auto-mode is disabled"
					;;
				22)                                                           # unavailable
					eventadd 140 "SWAP ($mnt_dev) NOT/NICHT"
					log_freetz notice "SWAP partition $mnt_dev was not mounted, rc.swap is not available"
					;;
				*)                                                            # error
					eventadd 140 "SWAP ($mnt_dev) NOT/NICHT"
					log_freetz err "SWAP partition $mnt_dev could not be mounted, error $err_fs_mount"
					mnt_failure=1
					;;
			esac
			;;
		*)
			[ -x "$(which led-ctrl)" ] && led-ctrl filesystem_mount_failure
			eventadd 142 "$mnt_name ($mnt_dev)" $fs_type
			log_freetz err "Partition $mnt_name ($mnt_dev): Unsupported filesystem or wrong partition table ($fs_type)"
			mnt_failure=1
			;;
	esac

	return $mnt_failure
}

# ummount function
# used by /etc/hotplug/storage
# separated from do_umount() since FW XX.04.86
#
# $1 - full mount point path (e.g. /var/media/ftp/uStor01)
#
do_umount_locked() {
	local mnt_path=$1                                                         # /var/media/ftp/uStorMN
	local mnt_name=${mnt_path##*/}                                            # uStorMN or LABEL
	local mnt_dev=$(grep -m 1 $mnt_path /proc/mounts | sed 's/ .*//')         # /dev/sdXY

	local rcftpd="/etc/init.d/rc.ftpd"
	[ -e /mod/etc/init.d/rc.smbd ] && local rcsmbd="/mod/etc/init.d/rc.smbd" || local rcsmbd="/etc/init.d/rc.smbd"
	local webdav_control="/etc/webdav_control"
	local fritznasdb_control="/etc/fritznasdb_control"
	local tammnt="/var/tam/mount"
	local autoend="$mnt_path/autoend.sh"

	# freetz extras
	[ "$MOD_STOR_AUTORUNEND" == "yes" -a -x $autoend ] && $autoend            # autoend
	[ -r /mod/etc/external.pkg ] && /etc/init.d/rc.external stop $mnt_path    # external
	[ -e /etc/init.d/rc.swap ] && /etc/init.d/rc.swap autostop $mnt_path      # swap

	# notify webdav & TAM unconditionally, i.e. before both "mount -o move" & the actual unmount (this is what AVM does)
	[ -x $webdav_control ] && $webdav_control lost_partition $mnt_path        # webdav
	[ -p $tammnt ] && echo "u$mnt_path" > $tammnt                             # TAM

	# notify other components before the actual unmount, this is NOT exactly the same what AVM does but quite close to it
	# AVM does it after "mount -o move" and before the actual unmount
	[ -x $fritznasdb_control ] && $fritznasdb_control lost_partition $mnt_path                           # fritznasdb
	[ -e /lib/libmediasrv.so ] && msgsend upnpd plugin notify libmediasrv.so "lost_partition:$mnt_path"  # mediasrv
	[ -e /lib/libcloudcds.so ] && msgsend upnpd plugin notify libcloudcds.so "lost_partition:$mnt_path"  # webdav based media server
	[ -e /lib/libgpmsrv.so   ] && msgsend upnpd plugin notify libgpmsrv.so   "lost_partition:$mnt_path"  # google play music
	[ -e /sbin/gpmdb         ] && msgsend gpmdb "lost_partition:$mnt_path"                               # google play music database

	# still some open files under $mnt_path ?
	if ls -l /proc/*/cwd /proc/*/fd/* 2>/dev/null | grep -q $mnt_path; then
		# wait some time to give AVM components a chance
		# to flush / to close the files under $mnt_path
		sleep 1
	fi

	umount $mnt_path > /dev/null 2>&1                                         # umount

	local smbd_needs_start=0
	if grep -q " $mnt_path " /proc/mounts; then                               # still mounted? try to stop smbd
		if [ -x $rcsmbd ]; then
			if [ "$($rcsmbd status)" != "stopped" ]; then
				smbd_needs_start=1
				$rcsmbd stop
				umount $mnt_path > /dev/null 2>&1
			fi
		fi
	fi

	local ftpd_needs_start=0
	if grep -q " $mnt_path " /proc/mounts; then                               # still mounted? try to stop ftpd
		if [ -x $rcftpd ]; then
			if [ "$($rcftpd status)" != "stopped" ]; then
				ftpd_needs_start=1
				$rcftpd stop
				umount $mnt_path > /dev/null 2>&1
			fi
		fi
	fi

	local SIGN pid umount_file umount_files umount_blocker
	if [ "$MOD_STOR_KILLBLOCKER" == "yes" ]; then                              # kill blocker
		for SIGN in TERM KILL; do
			if grep -q " $mnt_path " /proc/mounts; then                # still mounted?
				for pid in $(busybox ps | sed 's/^ *//g;s/ .*//g'); do
					umount_files="$(realpath /proc/$pid/cwd /proc/$pid/exe /proc/$pid/fd/* 2>/dev/null | grep $mnt_path)"
					if [ -n "$umount_files" ]; then
						umount_blocker="$mnt_path ($mnt_dev) - sending SIG$SIGN to [$pid] $(realpath /proc/$pid/exe):"
						for umount_file in $umount_files; do
							log_freetz notice "$umount_blocker $umount_file"
						done
						kill -$SIGN $pid >/dev/null 2>&1
					fi
				done
				sync
				umount $mnt_path > /dev/null 2>&1
			fi
		done
	fi

	if grep -v " hfsplus " /proc/mounts | grep -q " $mnt_path "; then         # mount ro
		log_freetz notice "$mnt_path ($mnt_dev) - mounting read-only"
		mount $mnt_path -o remount,ro
		umount $mnt_path > /dev/null 2>&1
	fi

	local err_code=0
	if grep -q " $mnt_path " /proc/mounts; then                               # still mounted? force unmount
		log_freetz notice "$mnt_path ($mnt_dev) - forcing unmount"
		umount -f $mnt_path
		err_code=$?
	fi

	if grep -q " $mnt_path " /proc/mounts; then                               # umount failed
		for pid in $(busybox ps | sed 's/^ *//g;s/ .*//g'); do            # log blocker
			umount_files="$(realpath /proc/$pid/cwd /proc/$pid/exe /proc/$pid/fd/* 2>/dev/null | grep $mnt_path)"
			if [ -n "$umount_files" ]; then
				umount_blocker="$mnt_path ($mnt_dev) - still used by $(realpath /proc/$pid/exe):"
				for umount_file in $umount_files; do
					log_freetz err "$umount_blocker $umount_file"
				done
			fi
		done

		eventadd 135 "$mnt_path ($mnt_dev)"
		log_freetz err "$mnt_path ($mnt_dev) - could not be unmounted"
	else                                                                      # umount succeeded
		# update device map
		grep -v ":$mnt_name$" $DEVMAP > /var/dev-$$.map
		mv -f /var/dev-$$.map $DEVMAP

		rmdir $mnt_path
		[ -d $mnt_path ] && log_freetz err "Directory $mnt_path could not be removed"

		eventadd 141 "Partition $mnt_name ($mnt_dev)"
		log_freetz notice "$mnt_path ($mnt_dev) - unmounted successfully"
	fi

	if [ $smbd_needs_start -eq 1 ]; then                                      # start smbd
		$rcsmbd start
	else
		[ -x /etc/samba_control ] && /etc/samba_control reconfig $mnt_path
	fi
	[ $ftpd_needs_start -eq 1 ] && $rcftpd start                              # start ftpd

	return $err_code
}

# mount function
# used by /etc/hotplug/storage
do_mount() {
	local device=$1
	local mnt_dev=$2
	local mnt_part_num=$3
	local err_code=0
	passeeren                                                                 # semaphore on
	do_mount_locked $device $mnt_dev $mnt_part_num
	err_code=$?
	vrijgeven                                                                 # semaphore off
	return $err_code
}

# ummount function
# used by /etc/hotplug/storage
do_umount() {
	if [ "${1:1:3}" == "dev" ]
	then                                                                      # old parameter style
		local mnt_path=$2                                                 # /var/media/ftp/uStorMN
	else                                                                      # new parameter style
		local mnt_path=$1                                                 # /var/media/ftp/uStorMN
	fi
	local err_code=0
	passeeren                                                                 # semaphore on
	do_umount_locked $mnt_path
	err_code=$?
	vrijgeven                                                                 # semaphore off
	return $err_code
}

# spindown control function
# used by /etc/hotplug/storage
hd_spindown_control() {
	local err_code=0
	[ $CONFIG_USB_STORAGE_SPINDOWN != "y" ] && return $err_code
	if [ "$1" = "force" ]; then
		log_freetz notice "force hd-idle for all sd[a-z] devices"
		for spin_dev in $(ls $SYSFS/block/ | grep -o "sd." ); do
			hd-idle -t $spin_dev 2> /dev/console
			err_code=$?
		done
	else
		local idle_time=0
		if [ "$1" = "loadconfig" ]; then
			if [ "$(echo usbhost.spindown_enabled | usbcfgctl -s)" = "yes" ]; then
				idle_time=$(echo usbhost.spindown_time | usbcfgctl -s)
			fi
		else
			local idle_time=$1
		fi
		if pidof hd-idle > /dev/null; then
			log_freetz notice "stopping hd-idle"
			killall hd-idle
			sleep 1
		fi
		if [ "$idle_time" -gt 0 ]; then
			log_freetz notice "starting hd-idle with $idle_time seconds"
			hd-idle -i $idle_time 2> /dev/console
			err_code=$?
		fi
	fi
	return $err_code
}

# patched section reload)
# of /etc/hotplug/storage
# reload storage media
storage_reload() {
	local rcftpd="/etc/init.d/rc.ftpd"
	[ -d /var/media ] || return 0
	[ -x $rcftpd ] && $rcftpd restart
	hd_spindown_control loadconfig
	return 0
}

# check if ctlmgr is the parent process of 'sh -c /etc/hotplug/storage unplug'
# if so, the unplug was initiated via AVM-web-if
# freetz internal function
is_ctlmgr_parent_of_storage_unplug() {
	local storage_unplug_parent_pid=$(busybox ps -l | awk '/sh -c \/etc\/hotplug\/storage (unplug|umount_usb)/ { print $4; }') # pid of parent of 'sh -c /etc/hotplug/storage unplug' (umount_usb since 5.5x)
	[ -z "${storage_unplug_parent_pid}" ] && return 1                                                                          # storage unplug is not listed under running processes => return false

	cat "/proc/${storage_unplug_parent_pid}/cmdline" 2>/dev/null | grep -q ctlmgr 2>/dev/null
}

# remove swap partition
# freetz internal function
remove_swap() {
	[ -e /etc/init.d/rc.swap ] || return 22
	if [ "${2:1:4}" == "proc" ]; then
		local mnt_dev_name=$3                                                 # new parameter style
	else
		local mnt_dev_name=$4                                                 # old parameter style
	fi
	local tmpret='/tmp/remove_swap.tmp'
	local retval=20                                                               # no swap devices found
	local swap_map="/proc/swaps"
	local swap_devs=$(grep "^/dev/$mnt_dev_name" $swap_map | sed 's/\t[\t]*/ /g;s/ [ ]*/ /g')
	if [ -n "$swap_devs" ]; then
		retval=21                                                             # swap devices found
		echo "$swap_devs" | while read -r swap_dev swap_type swap_size swap_used swap_prio; do
			if [ "$swap_type" == "partition" ]; then
				/etc/init.d/rc.swap autostop $swap_dev
				retval=$?
				echo $retval > ${tmpret}
				case "$retval" in
					0)
						eventadd 141 "SWAP Partition ($swap_dev)"
						log_freetz notice "SWAP Partition ($swap_dev) removed."
						;;
					2)
						eventadd 141 "SWAP Partition ($swap_dev) NOT/NICHT"
						log_freetz notice "SWAP Partition ($swap_dev) not removed, not the defined swap-partition."
						;;
					3)
						eventadd 141 "SWAP Partition ($swap_dev) NOT/NICHT"
						log_freetz notice "SWAP Partition ($swap_dev) not removed, auto-mode is disabled."
						;;
					*)
						eventadd 135 "SWAP Partition ($swap_dev)"
						log_freetz err "SWAP Partition ($swap_dev) could not be removed, error $retval."
						;;
				esac
			fi
		done
		retval="$(cat ${tmpret} 2>/dev/null)"
		rm -f ${tmpret} > /dev/null 2>&1
	fi
	return $retval
}

# patched section unplug)
# of /etc/hotplug/storage
# User initiated software-only unplug with sync
storage_unplug() {
	[ $# -lt 2 ] && return 11                                                 # not enough arguments
	MOUNT=$(grep " $2 " /proc/mounts)
	[ -z "$MOUNT" ] && return 2                                               # no mounts found
	set $MOUNT
	local mnt_dev=$1                                                          # /dev/sda1
	local mnt_path=$2                                                         # /var/media/ftp/uStorXY or LABEL
	local mnt_main_dev=${mnt_dev:5:3}                                         # sda
	local mserver_start="/sbin/start_mediasrv"
	local mserver_stop="/sbin/stop_mediasrv"
	local webdav_control="/etc/webdav_control"
	local remained_devs=""
	local unplug_ret=0
	[ -x $mserver_stop ] && $mserver_stop
	mount $mnt_path -o remount,ro
	[ -x $webdav_control ] && $webdav_control lost_all_partitions
	do_umount $mnt_path                                                       # unmount device
	unplug_ret=$?
	remained_devs=$(grep "$mnt_main_dev" /proc/mounts)                                                       # check for remained partitions on main device
	[ -z "$remained_devs" ] && is_ctlmgr_parent_of_storage_unplug && remove_swap dummy /proc "$mnt_main_dev" # remove swap partition if required
	[ -x $mserver_start ] && ! [ -f /var/DONTPLUG ] && [ -d /var/InternerSpeicher ] && $mserver_start        # restart media_serv if MP available
	return $unplug_ret
}
