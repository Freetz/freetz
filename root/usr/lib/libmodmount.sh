#! /bin/sh

[ -r /mod/etc/conf/mod.cfg ] && . /mod/etc/conf/mod.cfg

find_mnt_name ()
{
# modified name generation for automatic mount point
	local blkid_bin="/usr/sbin/blkid"
	local mnt_name=""
	[ "$3" == "0" ] && local mnt_device="/dev/$1" || local mnt_device="/dev/$1$3"
	local storage_prefix=$MOD_STOR_PREFIX
	[ -z "$storage_prefix" ] && storage_prefix="uStor"
	if [ "$MOD_STOR_USELABEL" == "yes" ]
	then
		[ -x $blkid_bin ] && mnt_name=$($blkid_bin -s LABEL $mnt_device | sed -e 's/.*LABEL="\([^"]*\)" /\1/' -e 's/ /_/g')
	fi
	[ -z "$mnt_name" ] && mnt_name="$storage_prefix$(echo $1 | sed 's/^..//;s/a/0/;s/b/1/;s/c/2/;s/d/3/;s/e/4/;s/f/5/;s/g/6/;s/h/7/;s/i/8/;s/j/9/')$3"
	echo $mnt_name
}

mount_fs ()
{
 # mount according to type of filesystem 
 # return exit code: true - all went well; other - something went wrong 
	local dev_node=$1 # device node
	local mnt_path=$2 # mount path
	[ $# -ge 3 ] && local rw_mode=$3 || local rw_mode=rw # read/write mode
	[ $# -ge 4 ] && local ftp_uid=$4 || local ftp_uid=0 # ftp user id
	[ $# -ge 5 ] && local ftp_gid=$5 || local ftp_gid=0 # ftp group id
	local blkid_bin="/usr/sbin/blkid"
	local fstyp_bin="/usr/bin/fstyp"
	local avm_ntfs="/bin/ntfs-3g"
	local freetz_ntfs="/usr/bin/ntfs-3g"
	local ntfs_bin="" # ntfs binary
	local err_mo=1 # set mount error as default
	local err_fst=1 # set file system detection error as default
	[ -x $avm_ntfs ] && ntfs_bin=$avm_ntfs
	[ -x $freetz_ntfs ] && ntfs_bin=$freetz_ntfs
	[ -x $fstyp_bin ] && local fs_type=$($fstyp_bin $mnt_dev 2>/dev/null) # fs type detection using fstyp binary
	[ -x $blkid_bin ] && local fs_type=$($blkid_bin -s TYPE $mnt_dev 2>/dev/null | sed -e 's/.*TYPE="//;s/".*//') # fs type detection using blkid binary
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
		err_mo=222 # SWAP Partition can not be mounted
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
{
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
			echo "Mounting $mnt_name to device $mnt_dev..." > /dev/ttyS0
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
		eventadd 140 $mnt_name
		[ -x $rcftpd ] && [ "$($rcftpd status)" != "running" ] && $rcftpd start # start ftpd, if not started
		local autorun="$mnt_path/autorun.sh"
		[ -x $autorun ] && $autorun & # run autostart shell script
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
				eventadd 144 $mnt_name # NTFS Volume was unclean unmount. Please unmount
				mnt_failure=0
			;;
			111 )
				echo "ntfs binary not found -> mount later" > /dev/ttyS0
				eventadd 145 $mnt_name "ntfs binary not found" # NTFS mount error (binary not found)
				mnt_failure=0
			;;
			* ) # general NTFS mount error
				eventadd 145 $mnt_name $err_fs_mount # NTFS mount error (error code)
				mnt_failure=0
			;;
			esac
		fi
		if [ "$fs_type" != "swap" ]
		then
			[ -x /bin/led-ctrl ] && /bin/led-ctrl filesystem_mount_failure
			eventadd 142 $mnt_name $fs_type # not supported file system or wrong partition table
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

do_umount ()
{
	local rcftpd="/etc/init.d/rc.ftpd"
	local rcsamba="/etc/init.d/rc.samba"
	local kill_daemon=""
	local kill_ftpd=0
	local kill_smbd=0
	local ftpd_needs_start=0
	local samba_needs_start=0
	local mnt_dev=$1
	local mnt_path=$2
	local mnt_name=$3
	local err_code=0
	local autoend="$mnt_path/autoend.sh"
	passeeren # semaphore on
	[ -x $autoend ] && $autoend
	[ -p "/var/tam/mount" ] && echo "u$mnt_path" > /var/tam/mount # TAM
	if ! $(umount $mnt_path > /dev/null 2>&1)
	then # 2
		samba_needs_start=1
		[ -x $rcsamba ] && $rcsamba stop smbd || kill_smbd=1 # stop smbd
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
					sleep 1
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
		eventadd 135 "$mnt_path"
	else
		grep -v ":$mnt_name$" $DEVMAP > /var/dev-$$.map
		mv -f /var/dev-$$.map $DEVMAP
		rmdir $mnt_path
		eventadd 141 $mnt_name
	fi
	sleep 1
	[ $samba_needs_start -eq 1 ] && [ -x $rcsamba ] && $rcsamba start # start samba
	[ $ftpd_needs_start -eq 1 ] && [ -x $rcftpd ] && $rcftpd start # start ftpd
	[ $samba_needs_start -eq 0 ] && [ -x /etc/samba_control ] && /etc/samba_control reconfig $mnt_path
	vrijgeven # semaphore off
	return $err_code
}

hd_spindown_control ()
{
	local err_code=0
	if [ $CONFIG_USB_STORAGE_SPINDOWN = "y" ]
	then
		if [ "$1" = "force" ]
		then
			echo "force hd-idle for all sd[a-z] devices">/dev/ttyS0
			for spin_dev in $(ls $SYSFS/block/ | grep -o "sd." )
			do
				hd-idle -t $spin_dev 2> /dev/ttyS0
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
				echo "stopping hd-idle" > /dev/ttyS0
				killall hd-idle
				sleep 1
			fi
			if [ "$idle_time" -gt 0 ]
			then
				echo "starting hd-idle with $idle_time seconds">/dev/ttyS0
				hd-idle -i $idle_time 2> /dev/ttyS0
				err_code=$?
			fi
		fi
	fi
	return $err_code
}

storage_reload ()
{ # reload storage media
	local rcftpd="/etc/init.d/rc.ftpd"
	[ -d /var/media ] || return 0
	[ -x $rcftpd ] && $rcftpd restart # restart ftpd
	hd_spindown_control loadconfig
	return 0
}

storage_unplug ()
{ # User initiated software-only unplug with sync
	local mserver_stop="/sbin/stop_mediasrv"
	local webdav_control="/etc/webdav_control"
	[ -z "$2" ] && return 11 # not enough arguments
	MOUNT=$(grep " $2 " /proc/mounts)
	[ -z "$MOUNT" ] && return 2 # none mounts found
	set $MOUNT
	mnt_dev=$1
	mnt_path=$2
	[ -x $mserver_stop ] && $mserver_stop
	[ -x $webdav_control ] && $webdav_control lost_all_partitions
	do_umount $mnt_dev $mnt_path ${mnt_path##*/} 0 # unmount device
	[ -d $mnt_path ] && return 1 # unmount failed
	return 0
}
