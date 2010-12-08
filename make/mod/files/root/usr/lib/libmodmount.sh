#! /bin/sh

[ -r /mod/etc/conf/mod.cfg ] && . /mod/etc/conf/mod.cfg

parent_process=$PPID

log_freetz ()
{ # FREETZ Syslog
	local log_prio="user.notice"
	[ "$1" == "err" ] && log_prio="user.err"
	logger -p "$log_prio" -t FREETZMOUNT "$2"
	return 0
}

check_parent ()
{ # check, if ctlmgr is parent process for storage unplug
	local parent_pid=$1
	local retval=1
	local top_filtered="$(top -b -n1 | sed '1,4d;s/\t/ /g;s/ [ ]*/ /g;/ \[.*]$/d;s/^ //;s/\([0-9]* [0-9]*\)[^%]*%[^%]*%\( .*\)/\1\2/')"
	local ctlmgr_pids=`echo "$top_filtered" | sed -n '/sed/d;/ctlmgr/s/\(^[0-9]*\) [0-9]*.*/\1/p'` # pids of all ctlmgr instancies
	local shc_parent_pid=$(echo "$top_filtered" | sed -n '/sh -c \/etc\/hotplug\/storage unplug/s/^[0-9]* \([0-9]*\).*/\1/p') # pid of parent of 'sh -c'
	local matched_pid=`echo "$ctlmgr_pids" | grep "$shc_parent_pid"` # is ctlmgr a parent process of 'sh -c /etc/hotplug/storage unplug' ?
	[ -n "$matched_pid" ] && retval=0 # unplug was initiated via AVM-WebIF
	return $retval
}

remove_swap ()
{ # remove swap partition
	if [ "${2:1:4}" == "proc" ]
	then # new parameter style
		local mnt_dev_name=$3	# sda
	else # old parameter style
		local mnt_dev_name=$4	# sda
	fi
	local tmpret='/tmp/remove_swap.tmp'
	local retval=20	# no swap devices found
	local swap_map="/proc/swaps"
	local swap_devs=`grep "^/dev/$mnt_dev_name" $swap_map | sed 's/\t[\t]*/ /g;s/ [ ]*/ /g'`
	if [ -n "$swap_devs" ]
	then
		retval=21 # swap devices found
		echo "$swap_devs" | while read -r swap_dev swap_type swap_size swap_used swap_prio
		do
			if [ $swap_type == "partition" ]
			then
				/etc/init.d/rc.swap autostop $swap_dev
				retval=$?
				echo $retval > ${tmpret}
				if [ $retval ]
				then
					eventadd 141 "SWAP Partition ($swap_dev)"
					log_freetz notice "SWAP Partition ($swap_dev) removed"
				else
					eventadd 135 "SWAP Partition ($swap_dev)"
					log_freetz err "SWAP Partition ($swap_dev) could not be removed"
				fi
			fi
		done
		retval=$(($(cat ${tmpret} 2>/dev/null)))
		rm -f ${tmpret} > /dev/null 2>&1
	fi
	return $retval
}

find_mnt_name ()
{ # modified name generation for automatic mount point
	local blkid_bin="/usr/sbin/blkid"
	local retfind=0
	local mnt_name=""
	[ "$3" == "0" ] && local mnt_device="/dev/$1" || local mnt_device="/dev/$1$3"
	local storage_prefix="$MOD_STOR_PREFIX"
	[ -z "$storage_prefix" ] && storage_prefix="uStor"
	[ "$MOD_STOR_PREFIX"=="$storage_prefix" ] || retfind=10 # User defined prefix
	if [ "$MOD_STOR_USELABEL" == "yes" ]
	then
		[ -x $blkid_bin ] && mnt_name=$($blkid_bin -s LABEL -o value $mnt_device | sed 's/ /_/g')
	fi
	if [ -z "$mnt_name" ]
	then # Name was generated using prefix and numbers like uStorXY
		mnt_name="$storage_prefix$(echo $1 | sed 's/^..//;s/a/0/;s/b/1/;s/c/2/;s/d/3/;s/e/4/;s/f/5/;s/g/6/;s/h/7/;s/i/8/;s/j/9/')$3"
	else # Name was generated using LABEL
		retfind=20
	fi
	echo $mnt_name
	return $retfind
}

mount_fs ()
{ # mount according to type of filesystem
  # return exit code: true - all went well; other - something went wrong
	local dev_node=$1 # device node
	local mnt_path=$2 # mount path
	[ $# -ge 3 ] && local rw_mode=$3 || local rw_mode=rw # read/write mode
	[ $# -ge 4 ] && local ftp_uid=$4 || local ftp_uid=0 # ftp user id
	[ $# -ge 5 ] && local ftp_gid=$5 || local ftp_gid=0 # ftp group id
	local blkid_bin="/usr/sbin/blkid"
	local fstyp_bin="/usr/bin/fstyp"
	local ntfs_bin="/bin/ntfs-3g"
	local err_mo=1 # set mount error as default
	local err_fst=1 # set file system detection error as default
	if [ -x $fstyp_bin ]; then
		local fs_type=$($fstyp_bin $mnt_dev 2>/dev/null) # fs type detection using fstyp binary
	elif [ -x $blkid_bin ]; then
		local fs_type=$($blkid_bin -s TYPE $mnt_dev 2>/dev/null | sed -e 's/.*TYPE="//;s/".*//') # fs type detection using blkid binary
	fi
	[ -z "$fs_type" ] && local fs_type="unknown" # set unknown file system type if detection failed
	case $fs_type in
	vfat)
		mount -t vfat -o $rw_mode,uid=$ftp_uid,gid=$ftp_gid,fmask=0000,dmask=0000 $dev_node $mnt_path
		err_mo=$?
	;;
	ext2)
		mount -t ext2 $dev_node $mnt_path -o noatime,nodiratime,rw,async
		err_mo=$?
	;;
	ext3)
		mount -t ext3 $dev_node $mnt_path -o noatime,nodiratime,rw,async
		err_mo=$?
	;;
	ntfs)
		[ -n "$ntfs_bin" ] && { $ntfs_bin $dev_node $mnt_path -o force ; err_mo=$? ; } || err_mo=111
	;;
	reiserfs)
		mount -t reiserfs $dev_node $mnt_path -o noatime,nodiratime,rw,async
		err_mo=$?
	;;
	swap)
		/etc/init.d/rc.swap autostart $dev_node
		[ $?==0 ] && err_mo=17 || err_mo=18
	;;
	*) # fs type unknown
		mount $dev_node $mnt_path
		err_mo=$?
	;;
	esac
	echo -n "$fs_type"
	return $err_mo
}

do_mount ()
{ # mount function, used by /etc/hotplug/run_mount
	local mnt_failure=1
	local rcftpd="/etc/init.d/rc.ftpd"
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
	passeeren # semaphore on
	if mount | grep "$mnt_dev on /var/media/" > /dev/null
	then # device already mounted
		vrijgeven # semaphore off
		return 0
	fi
	while [ $mnt_med_num -le 9 ] # sda1...sda9
	do
		mnt_name=$(find_mnt_name $mnt_main_dev $mnt_med_num $mnt_part_num) # find name
		mnt_path=$FTPDIR/$mnt_name
		if [ ! -d $mnt_path ]
		then
			echo "Mounting $mnt_name to device $mnt_dev ... " > /dev/console
			log_freetz notice "Mounting $mnt_name to device $mnt_dev ... "
			mkdir -p $mnt_path
			break
		else
			let mnt_med_num++
		fi
	done
	chmod 755 $FTPDIR # chmod for ftp top directory
	local old_umask=$(umask) # store actual mask
	umask 0
	fs_type=$(mount_fs $mnt_dev $mnt_path $mnt_rw $FTPUID $FTPGID) # FREETZ mount
	local err_fs_mount=$?
	if [ $err_fs_mount -eq 0 ]
	then
		mnt_failure=0
		umask $old_umask
		eventadd 140 "$mnt_name ($mnt_dev)"
		log_freetz notice "Partition $mnt_name ($mnt_dev) was mounted successfully"
		[ -x $rcftpd ] && [ "$($rcftpd status)" != "running" ] && $rcftpd start # start ftpd, if not started
		/etc/init.d/rc.swap autostart $mnt_path
		local autorun="$mnt_path/autorun.sh"
		[ "$MOD_STOR_AUTORUNEND" == "yes" -a -x $autorun ] && $autorun & # run autostart shell script
		[ -r /etc/external.pkg ] && /etc/init.d/rc.external start $mnt_path &
		[ -x $TR069START ] && $TR069START $mnt_name # run tr069
		[ -x /etc/samba_control ] && /etc/samba_control reconfig # SAMBA reconfiguration
		[ -p $tammnt ] && echo "m$mnt_path" > $tammnt
		rm -f /var/media/NEW_LINK && ln -f -s $mnt_path /var/media/NEW_LINK # mark last mounted partition
		msgsend multid update_usb_infos # upnp
		[ -x /bin/led-ctrl ] && /bin/led-ctrl filesystem_done
	else
		if [ "$fs_type" == "ntfs" ]
		then
			case $err_fs_mount in
			15 ) # NTFS unclean unmount
				eventadd 144 "$mnt_name ($mnt_dev)" # NTFS Volume was unclean unmount. Please unmount
				log_freetz err "Partition $mnt_name ($mnt_dev): NTFS Volume was unclean unmount. Please unmount"
				mnt_failure=0
			;;
			111 )
				echo "ntfs binary not found -> mount later" > /dev/console
				eventadd 145 "$mnt_name ($mnt_dev)" "ntfs binary not found" # NTFS mount error (binary not found)
				log_freetz err "Partition $mnt_name ($mnt_dev): NTFS mount error (binary not found)"
				mnt_failure=0
			;;
			* ) # general NTFS mount error
				eventadd 145 "$mnt_name ($mnt_dev)" $err_fs_mount # NTFS mount error (error code)
				log_freetz err "Partition $mnt_name ($mnt_dev): NTFS mount error ($err_fs_mount)"
				mnt_failure=0
			;;
			esac
		fi
		if [ "$fs_type" == "swap" ]
		then
			if [ $err_fs_mount -eq 17 ]
			then
				mnt_failure=0
				eventadd 140 "SWAP ($mnt_dev)"
				log_freetz notice "SWAP Partition $mnt_name ($mnt_dev) was mounted successfully"
			else
				mnt_failure=1
				eventadd 140 "SWAP ($mnt_dev) NOT/NICHT"
				log_freetz err "SWAP Partition $mnt_name ($mnt_dev) could not be mounted"
			fi
		else
			[ -x /bin/led-ctrl ] && /bin/led-ctrl filesystem_mount_failure
			eventadd 142 "$mnt_name ($mnt_dev)" $fs_type # not supported file system or wrong partition table
			log_freetz err "Partition $mnt_name ($mnt_dev): Not supported file system or wrong partition table"
		fi
		umask $old_umask
		rmdir $mnt_path
	fi

	if grep $mnt_path /proc/mounts > /dev/null
	then
		if [ -f "$1" ]
		then
			cat $DEVMAP | grep -v "^$1=$2:" > /var/dev-$$.map
			echo "$1=$2:$mnt_name" >> /var/dev-$$.map
			mv -f /var/dev-$$.map $DEVMAP
		fi
	fi
	vrijgeven # semaphore off
	return $mnt_failure
}

do_umount_locked ()
{ # ummount function, used by /etc/hotplug/storage
  # separated from do_umount since FW XX.04.86
	local rcftpd="/etc/init.d/rc.ftpd"
	local rcsmbd="/etc/init.d/rc.smbd"
	local kill_daemon=""
	local kill_ftpd=0
	local kill_smbd=0
	local ftpd_needs_start=0
	local samba_needs_start=0
	local mnt_path=$1	# /var/media/ftp/uStorMN
	local mnt_name=$2	# uStorMN or LABEL
	local err_code=0
	local autoend="$mnt_path/autoend.sh"
	local mnt_dev=`grep -m 1 "$mnt_path" /proc/mounts | sed 's/ .*//'` # /dev/sdXY
	[ "$MOD_STOR_AUTORUNEND" == "yes" -a  -x $autoend ] && $autoend
	[ -r /etc/external.pkg ] && /etc/init.d/rc.external stop $mnt_path
	/etc/init.d/rc.swap autostop $mnt_path
	mount "$mnt_path" -o remount,ro
	[ -p "/var/tam/mount" ] && echo "u$mnt_path" > /var/tam/mount # TAM
	if ! $(umount $mnt_path > /dev/null 2>&1)
	then # 2
		samba_needs_start=1
		[ -x $rcsmbd ] && $rcsmbd stop || kill_smbd=1 # stop smbd
		if ! $(umount $mnt_path > /dev/null 2>&1)
		then # 3
			ftpd_needs_start=1
			[ -x $rcftpd ] && $rcftpd stop || kill_ftpd=1 # stop ftpd
			if ! $(umount $mnt_path > /dev/null 2>&1)
			then # 4
				[ $kill_ftpd -eq 1 ] && kill_daemon="ftpd"
				[ $kill_smbd -eq 1 ] && kill_daemon="$kill_daemon smbd"
				if [ -n "$kill_daemon" ]
				then
					for pid in $(pidof $kill_daemon)
					do
						ls -l /proc/$pid/cwd /proc/$pid/fd | grep $mnt_path > /dev/null 2>&1 && kill $pid
					done
					sleep 5
				fi
				if ! $(umount $mnt_path)
				then # last attempt: force
					sleep 1
					umount -f $mnt_path
					err_code=$?
				fi
			fi
		fi
	fi
	if grep " $mnt_path " /proc/mounts > /dev/null 2>&1
	then ## still mounted
		eventadd 135 "$mnt_path ($mnt_dev)"
		echo "ERROR: Partition $mnt_name could not be unmount" > /dev/console
		log_freetz err "Partition $mnt_name ($mnt_dev) could not be unmount"
	else
		grep -v ":$mnt_name$" $DEVMAP > /var/dev-$$.map
		mv -f /var/dev-$$.map $DEVMAP
		rmdir $mnt_path
		[ -d "$mnt_path" ] && echo "ERROR: Directory $mnt_path could not be removed" > /dev/console
		eventadd 141 "Partition $mnt_name ($mnt_dev)"
		log_freetz notice "Partition $mnt_name ($mnt_dev) removed"
	fi
	sleep 1
	[ $samba_needs_start -eq 1 ] && [ -x $rcsmbd ] && $rcsmbd start # start smbd
	[ $ftpd_needs_start -eq 1 ] && [ -x $rcftpd ] && $rcftpd start # start ftpd
	[ $samba_needs_start -eq 0 ] && [ -x /etc/samba_control ] && /etc/samba_control reconfig $mnt_path
	return $err_code
}

do_umount ()
{ # ummount function, used by /etc/hotplug/storage
	if [ "${1:1:3}" == "dev" ]
	then # old parameter style
		local mnt_path=$2	# /var/media/ftp/uStorMN
		local mnt_name=$3	# uStorMN or LABEL
	else # new parameter style
		local mnt_path=$1	# /var/media/ftp/uStorMN
		local mnt_name=$2	# uStorMN or LABEL
	fi
	local err_code=0
	passeeren # semaphore on
	do_umount_locked "$mnt_path" "$mnt_name"
	err_code=$?
	vrijgeven # semaphore off
	return $err_code
}

hd_spindown_control ()
{ # spindown control function, used by /etc/hotplug/storage
	local err_code=0
	if [ $CONFIG_USB_STORAGE_SPINDOWN = "y" ]
	then
		if [ "$1" = "force" ]
		then
			echo "force hd-idle for all sd[a-z] devices">/dev/console
			log_freetz notice "force hd-idle for all sd[a-z] devices"
			for spin_dev in $(ls $SYSFS/block/ | grep -o "sd." )
			do
				hd-idle -t $spin_dev 2> /dev/console
				err_code=$?
			done
		else
			if [ "$1" = "loadconfig" ]
			then
				local idle_time=0
				local spindown_allowed=$(echo usbhost.spindown_enabled | usbcfgctl -s)
				[ "$spindown_allowed" = "yes" ] && idle_time=$(echo usbhost.spindown_time | usbcfgctl -s)
			else
				local idle_time=$1
			fi
			if pidof hd-idle > /dev/null
			then
				echo "stopping hd-idle" > /dev/console
				log_freetz notice "stopping hd-idle"
				killall hd-idle
				sleep 1
			fi
			if [ "$idle_time" -gt 0 ]
			then
				echo "starting hd-idle with $idle_time seconds">/dev/console
				log_freetz notice "starting hd-idle with $idle_time seconds"
				hd-idle -i $idle_time 2> /dev/console
				err_code=$?
			fi
		fi
	fi
	return $err_code
}

storage_reload ()
{ # patched section reload) of /etc/hotplug/storage
  # reload storage media
	local rcftpd="/etc/init.d/rc.ftpd"
	[ -d /var/media ] || return 0
	[ -x $rcftpd ] && $rcftpd restart # restart ftpd
	hd_spindown_control loadconfig
	return 0
}

storage_unplug ()
{ # patched section unplug) of /etc/hotplug/storage
  # User initiated software-only unplug with sync
	[ -z "$2" ] && return 11 # not enough arguments
	MOUNT=$(grep " $2 " /proc/mounts)
	[ -z "$MOUNT" ] && return 2 # none mounts found
	set $MOUNT
	local mnt_dev=$1	# /dev/sda1
	local mnt_path=$2	# /var/media/ftp/uStorXY or LABEL
	local mnt_name="${mnt_path##*/}"	# uStorXY or LABEL
	local mnt_main_dev=${mnt_dev:5:3}	# sda
	local mserver_start="/sbin/start_mediasrv"
	local mserver_stop="/sbin/stop_mediasrv"
	local webdav_control="/etc/webdav_control"
	local remained_devs=""
	local unplug_ret=0
	[ -x $mserver_stop ] && $mserver_stop
	mount "$mnt_path" -o remount,ro
	[ -x $webdav_control ] && $webdav_control lost_all_partitions
	do_umount "$mnt_path" "$mnt_name" # unmount device
	unplug_ret=$?
	remained_devs=`grep "$mnt_main_dev" /proc/mounts` # check for remained partitions on main device
	[ -z "$remained_devs" ] && check_parent $parent_process && remove_swap dummy /proc "$mnt_main_dev" # remove swap partition if required
	[ -x $mserver_start ] && ! [ -f /var/DONTPLUG ] && [ -d /var/InternerSpeicher ] && $mserver_start # restart media_serv if MP available
	return $unplug_ret
}
