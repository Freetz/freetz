#! /bin/sh

[ -r /mod/etc/conf/mod.cfg ] && . /mod/etc/conf/mod.cfg

parent_process=$PPID

# Log to Syslog & Console
log_freetz() {
	local log_prio="user.notice"
	local c_prefix='[INFO]'
	[ "$1" == "err" ] && log_prio="user.err" && c_prefix='[FAIL]'
	logger -p "$log_prio" -t FREETZMOUNT "$2"
	echo "FREETZMOUNT: $c_prefix $2" > /dev/console
	echo "$c_prefix $2" >> /var/log/mod_mount.log
	return 0
}

#XXX
# check, if ctlmgr is parent process for storage unplug
check_parent() {
	local parent_pid=$1
	local retval=1
	local top_filtered="$(top -b -n1 | sed '1,4d;s/\t/ /g;s/ [ ]*/ /g;/ \[.*]$/d;s/^ //;s/\([0-9]* [0-9]*\)[^%]*%[^%]*%\( .*\)/\1\2/')"
	local ctlmgr_pids=`echo "$top_filtered" | sed -n '/sed/d;/ctlmgr/s/\(^[0-9]*\) [0-9]*.*/\1/p'` # pids of all ctlmgr instances
	local shc_parent_pid=$(echo "$top_filtered" | sed -n '/sh -c \/etc\/hotplug\/storage unplug/s/^[0-9]* \([0-9]*\).*/\1/p') # pid of parent of 'sh -c'
	local matched_pid=`echo "$ctlmgr_pids" | grep "$shc_parent_pid"` # is ctlmgr a parent process of 'sh -c /etc/hotplug/storage unplug' ?
	[ -n "$matched_pid" ] && retval=0 # unplug was initiated via AVM-WebIF
	return $retval
}

# remove swap partition
remove_swap() {
	if [ "${2:1:4}" == "proc" ]; then
		local mnt_dev_name=$3                                                 # new parameter style
	else
		local mnt_dev_name=$4                                                 # old parameter style
	fi
	local tmpret='/tmp/remove_swap.tmp'
	local retval=20                                                           # no swap devices found
	local swap_map="/proc/swaps"
	local swap_devs=`grep "^/dev/$mnt_dev_name" $swap_map | sed 's/\t[\t]*/ /g;s/ [ ]*/ /g'`
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

# modified name generation for automatic mount point
find_mnt_name() {
	local retfind=0
	local mnt_name=""
	[ "$3" == "0" ] && local mnt_device="/dev/$1" || local mnt_device="/dev/$1$3"
	local storage_prefix="${MOD_STOR_PREFIX-uStor}"
	[ "$MOD_STOR_PREFIX"=="$storage_prefix" ] || retfind=10 # User defined prefix
	[ "$MOD_STOR_USELABEL" == "yes" ] && mnt_name="$(blkid $mnt_device | sed -rn 's!.*LABEL="([^"]*).*!\1!p')"
	if [ -z "$mnt_name" ]; then # Name was generated using prefix and numbers like uStorXY
		mnt_name="$storage_prefix$(echo $1 | sed 's/^..//;s/a/0/;s/b/1/;s/c/2/;s/d/3/;s/e/4/;s/f/5/;s/g/6/;s/h/7/;s/i/8/;s/j/9/')$3"
	else # Name was generated using LABEL
		retfind=20
	fi
	echo $mnt_name
	return $retfind
}

# mount according to type of filesystem
# return code:
#  true - all went well
#  other - something went wrong
mount_fs() {
	local dev_node=$1                                                         # device node
	local mnt_path=$2                                                         # mount path
	[ $# -ge 3 ] && local rw_mode=$3 || local rw_mode=rw                      # read/write mode
	[ $# -ge 4 ] && local ftp_uid=$4 || local ftp_uid=0                       # ftp user id
	[ $# -ge 5 ] && local ftp_gid=$5 || local ftp_gid=0                       # ftp group id
	local err_mo=1                                                            # set mount error as default
	local err_fst=1                                                           # set file system detection error as default
	local fs_type="$(blkid $dev_node | sed -nr 's!.*TYPE="([^"]*).*!\1!p')"   # fs type detection
	[ -z "$fs_type" ] && local fs_type="unknown"                              # set unknown file system type if detection failed
	case $fs_type in
		vfat)
			mount -t vfat -o $rw_mode,uid=$ftp_uid,gid=$ftp_gid,fmask=0000,dmask=0000 $dev_node $mnt_path
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
			local ntfs_bin="/bin/ntfs-3g"
			[ -x "$ntfs_bin" ] && { $ntfs_bin $dev_node $mnt_path -o force ; err_mo=$? ; } || err_mo=111
			;;
		swap)
			/etc/init.d/rc.swap autostart $dev_node
			err_mo=$((17+$?))
			;;
		*)                                                                    # fs type unknown
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
do_mount_locked() {
	local mnt_failure=0
	local rcftpd="/etc/init.d/rc.ftpd"
	local fritznasdb_control="/etc/fritznasdb_control"
	local tammnt="/var/tam/mount"
	local mnt_rw=rw
	[ $# -ge 2 ] && local mnt_dev=$2 || return 1
	[ $# -ge 3 ] && local mnt_part_num=$3 || return 1
	local mnt_blk_dev=${mnt_dev##/dev/}
	local mnt_main_dev=$(echo $mnt_blk_dev | sed -e 's#\(.\{0,3\}\).*#\1#g')
	local mnt_med_num=0
	local mnt_name
	local mnt_path
	local fs_type
	mount | grep -q "$mnt_dev on /var/media/" && return 0                     # device already mounted
	while [ $mnt_med_num -le 9 ]; do                                          # sda1...sda9
		mnt_name=$(find_mnt_name $mnt_main_dev $mnt_med_num $mnt_part_num)    # find name
		mnt_path=$FTPDIR/$mnt_name
		if [ ! -d $mnt_path ]; then
			log_freetz notice "Mounting device $mnt_dev ... "
			mkdir -p $mnt_path
			break
		fi
		let mnt_med_num++
	done
	chmod 755 $FTPDIR                                                         # chmod for ftp top directory
	local old_umask=$(umask)                                                  # store actual mask
	umask 0
	fs_type=$(mount_fs $mnt_dev $mnt_path $mnt_rw $FTPUID $FTPGID)            # FREETZ mount
	local err_fs_mount=$?
	if [ $err_fs_mount -eq 0 ]; then
		umask $old_umask
		eventadd 140 "$mnt_name ($mnt_dev)"
		log_freetz notice "Partition $mnt_name ($mnt_dev) was mounted successfully ($fs_type)"
		if [ -x $rcftpd ]; then                                                   # start/enable ftpd
			[ -x "$(which inetdctl)" ] && inetdctl enable ftpd || $rcftpd start
		fi
		/etc/init.d/rc.swap autostart $mnt_path                                   # swap
		local autorun="$mnt_path/autorun.sh"
		[ "$MOD_STOR_AUTORUNEND" == "yes" -a -x $autorun ] && $autorun &          # autorun
		[ -r /mod/etc/external.pkg ] && /etc/init.d/rc.external start $mnt_path & # external
		[ -x $TR069START ] && $TR069START $mnt_name                               # tr069
		[ -x /etc/samba_control ] && /etc/samba_control reconfig                  # SAMBA reconfiguration
		[ -p $tammnt ] && echo "m$mnt_path" > $tammnt                             # tam
		rm -f /var/media/NEW_LINK && ln -f -s $mnt_path /var/media/NEW_LINK       # mark last mounted partition
		msgsend multid update_usb_infos                                           # upnp
		if [ -x $fritznasdb_control ]; then
			msgsend upnpd plugin force_notify libmediasrv.so new_partition    # mediasrv
			$fritznasdb_control new_partition "$mnt_path"                     # fritznasdb
		fi
		[ -x /bin/led-ctrl ] && /bin/led-ctrl filesystem_done                     # led
	else
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
				*)                                                            # error
					eventadd 140 "SWAP ($mnt_dev) NOT/NICHT"
					log_freetz err "SWAP partition $mnt_dev could not be mounted, error $err_fs_mount"
					mnt_failure=1
					;;
			esac
			;;
		*)
			[ -x /bin/led-ctrl ] && /bin/led-ctrl filesystem_mount_failure
			eventadd 142 "$mnt_name ($mnt_dev)" $fs_type
			log_freetz err "Partition $mnt_name ($mnt_dev): Unsupported filesystem or wrong partition table ($fs_type)"
			mnt_failure=1
			;;
		esac
		umask $old_umask
		rmdir $mnt_path
	fi

	if grep -q $mnt_path /proc/mounts; then
		if [ -f "$1" ]; then
			grep -v "^$1=$2:" $DEVMAP > /var/dev-$$.map
			echo "$1=$2:$mnt_name" >> /var/dev-$$.map
			mv -f /var/dev-$$.map $DEVMAP
		fi
	fi
	return $mnt_failure
}

# ummount function
# used by /etc/hotplug/storage
# separated from do_umount() since FW XX.04.86
do_umount_locked() {
	local rcftpd="/etc/init.d/rc.ftpd"
	[ -e /mod/etc/init.d/rc.smbd ] && local rcsmbd="/mod/etc/init.d/rc.smbd" || local rcsmbd="/etc/init.d/rc.smbd"
	local fritznasdb_control="/etc/fritznasdb_control"
	local kill_daemon=""
	local ftpd_needs_start=0
	local smbd_needs_start=0
	local mnt_path=$1                                                         # /var/media/ftp/uStorMN
	local mnt_name=$2                                                         # uStorMN or LABEL
	local err_code=0
	local autoend="$mnt_path/autoend.sh"
	local mnt_dev=`grep -m 1 "$mnt_path" /proc/mounts | sed 's/ .*//'`        # /dev/sdXY
	[ "$MOD_STOR_AUTORUNEND" == "yes" -a -x $autoend ] && $autoend            # autoend
	[ -r /mod/etc/external.pkg ] && /etc/init.d/rc.external stop $mnt_path    # external
	/etc/init.d/rc.swap autostop $mnt_path                                    # swap
	if [ -x $fritznasdb_control ]; then
		$fritznasdb_control lost_partition $mnt_path                          # fritznasdb
		msgsend upnpd plugin notify libmediasrv.so "lost_partition:$mnt_path" # medisrv
	fi
	[ -p "/var/tam/mount" ] && echo "u$mnt_path" > /var/tam/mount             # TAM

	umount $mnt_path > /dev/null 2>&1                                         # umount

	if grep -q " $mnt_path " /proc/mounts; then                               # stop smbd
		if [ -x $rcsmbd ]; then
			if [ "$($rcsmbd status)" != "stopped" ]; then
				smbd_needs_start=1
			 	$rcsmbd stop
			 	umount $mnt_path > /dev/null 2>&1
			 fi
		fi
	fi

	if grep -q " $mnt_path " /proc/mounts; then                               # stop ftpd
		if [ -x $rcftpd ]; then
			if [ "$($rcftpd status)" != "stopped" ]; then
				ftpd_needs_start=1
			 	$rcftpd stop
			 	umount $mnt_path > /dev/null 2>&1
			 fi
		fi
	fi

	if [ "$MOD_STOR_KILLBLOCKER" == "yes" ]; then                              # kill blocker
		for SIGN in TERM KILL; do
			if grep -q " $mnt_path " /proc/mounts; then
				for pid in $(ps | sed 's/^ *//g;s/ .*//g'); do
					umount_files="$(realpath /proc/$pid/cwd /proc/$pid/fd/* 2>/dev/null | grep $mnt_path)"
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
		mount "$mnt_path" -o remount,ro
	 	umount $mnt_path > /dev/null 2>&1
	fi

	if grep -q " $mnt_path " /proc/mounts; then                               # force umount
		log_freetz notice "$mnt_path ($mnt_dev) - forcing unmount"
		umount -f $mnt_path
		err_code=$?
	fi

	if grep -q " $mnt_path " /proc/mounts; then                               # umount failed
		for pid in $(ps | sed 's/^ *//g;s/ .*//g'); do                        # log blocker
			umount_files="$(realpath /proc/$pid/cwd /proc/$pid/fd/* 2>/dev/null | grep $mnt_path)"
			if [ -n "$umount_files" ]; then
				umount_blocker="$mnt_path ($mnt_dev) - still used by $(realpath /proc/$pid/exe):"
				for umount_file in $umount_files; do
					log_freetz err "$umount_blocker $umount_file"
				done
			fi
		done
		eventadd 135 "$mnt_path ($mnt_dev)"
		log_freetz err "$mnt_path ($mnt_dev) - could not be unmounted"
	else                                                                      # umount sucessfully
		grep -v ":$mnt_name$" $DEVMAP > /var/dev-$$.map
		mv -f /var/dev-$$.map $DEVMAP
		rmdir $mnt_path
		[ -d "$mnt_path" ] && log_freetz err "Directory $mnt_path could not be removed"
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
		local mnt_path=$2                                                     # /var/media/ftp/uStorMN
		local mnt_name=$3                                                     # uStorMN or LABEL
	else                                                                      # new parameter style
		local mnt_path=$1                                                     # /var/media/ftp/uStorMN
		local mnt_name=$2                                                     # uStorMN or LABEL
	fi
	local err_code=0
	passeeren                                                                 # semaphore on
	do_umount_locked "$mnt_path" "$mnt_name"
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
	local mnt_name="${mnt_path##*/}"                                          # uStorXY or LABEL
	local mnt_main_dev=${mnt_dev:5:3}                                         # sda
	local mserver_start="/sbin/start_mediasrv"
	local mserver_stop="/sbin/stop_mediasrv"
	local webdav_control="/etc/webdav_control"
	local remained_devs=""
	local unplug_ret=0
	[ -x $mserver_stop ] && $mserver_stop
	mount "$mnt_path" -o remount,ro
	[ -x $webdav_control ] && $webdav_control lost_all_partitions
	do_umount "$mnt_path" "$mnt_name"                                         # unmount device
	unplug_ret=$?
	remained_devs=`grep "$mnt_main_dev" /proc/mounts`                         # check for remained partitions on main device
	[ -z "$remained_devs" ] && check_parent $parent_process && remove_swap dummy /proc "$mnt_main_dev"     # remove swap partition if required
	[ -x $mserver_start ] && ! [ -f /var/DONTPLUG ] && [ -d /var/InternerSpeicher ] && $mserver_start      # restart media_serv if MP available
	return $unplug_ret
}
