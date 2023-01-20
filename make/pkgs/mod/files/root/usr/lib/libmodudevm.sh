#!/bin/sh
. /etc/init.d/loglibrc

udev_log() {
	loglib_system "UDEVMOUNT" "$2"
	if [ "$1" != 'X' ]; then
		local pfix
		[ "$1" != '0' ] && pfix='[FAIL]' || pfix='[INFO]'
		echo "$pfix $2" >> /var/log/mod_mount.log
	fi
}

# used by /etc/hotplug/udev-mount-sd
# $1 (UDEVICE) /dev/bus/usb/00Y/00X (before 06.25: /proc/bus/usb/00X/00Y - since 06.25 00X/00Y)
# $2 (DEVNODE) /dev/sdZX (block device)
# $3 (PARTNUM) X (partition number)
do_mount_locked() {
	local _BD="$2"
	udev_log X "$_BD - mounting started"

	REAL__do_mount_locked $*
	local _RV=$?

	local _FS="$(sed -nr "s,^${_BD} [^ ]* ([^ ]*).*,\1,p" /proc/mounts)"
	if [ "$_RV" != "0" ]; then
		# Special case SWAP partition
		if [ "$(modconf value MOD_SWAP mod)" == "yes" ]; then
			local _SWAP_DEV="$(modconf value MOD_SWAP_FILE mod | grep '/dev')"
			if [ "$_SWAP_DEV" == "$_BD" ]; then
				[ -e /etc/init.d/rc.swap ] && /etc/init.d/rc.swap autostart "$_BD"
				_RV=$?
			fi
		fi
		if $_RV; then
			eventadd 142 "Partition $_BD" "$_FS"
			udev_log $_RV "$_BD - unsupported filesystem or partition table${_FS:+: $_FS}"
		else
			eventadd 140 "SWAP Partition $_BD"
			udev_log $_RV "$_BD - mounted as SWAP partition"
		fi
	else
		local _MP="$(sed -rn "s,^$_BD ([^ ]*).*,\1,p" /proc/mounts)"

		eventadd 140 "Partition $_MP ($_BD)"
		udev_log $_RV "$_BD - mounted as $_MP ($_FS)"

		[ -e /etc/init.d/rc.swap ] && /etc/init.d/rc.swap autostart "$_MP"
		[ -x "$_MP/autorun.sh" ] && [ "$(modconf value MOD_STOR_AUTORUNEND mod)" == "yes" ] && "$_MP/autorun.sh"
		[ -r /mod/etc/external.pkg ] && /etc/init.d/rc.external start "$_MP"
	fi

	return $_RV
}

# used by /etc/hotplug/udev-mount-sd and /etc/hotplug/storage
# $1 ($MPOINT or $MP) /var/media/ftp/LABEL
# $2 ($MPNAME or UNSET in udev-mount-sd) LABEL
do_umount_locked() {
	local _MP="$1"
	local _BD="$(sed -rn "s,^([^ ]*) ${_MP} .*,\1,p" /proc/mounts)"
	local DUMP='/var/media/dump_partition'
	udev_log X "$_BD ($_MP) - unmounting started"

	[ -r /mod/etc/external.pkg ] && /etc/init.d/rc.external stop "$_MP"
	[ -x "$_MP/autoend.sh" ] && [ "$(modconf value MOD_STOR_AUTORUNEND mod)" == "yes" ] && "$_MP/autoend.sh"
	[ -e /etc/init.d/rc.swap ] && /etc/init.d/rc.swap autostop "$_MP"

	REAL__do_umount_locked $*
	local _RV=$?

	if grep -q "^$_BD " /proc/mounts; then                                       # blocker
		if [ "$(modconf value MOD_STOR_KILLBLOCKER mod)" == "yes" ]; then 
			local SIGN pid umount_file umount_files umount_blocker
			for SIGN in TERM KILL; do
				grep -q "^$_BD " /proc/mounts || continue
				for pid in $(busybox ps | sed 's/^ *//g;s/ .*//g'); do
					umount_files="$(realpath /proc/$pid/cwd /proc/$pid/exe /proc/$pid/fd/* 2>/dev/null | grep -E "$_MP|$DUMP")"
					[ -z "$umount_files" ] && continue
					umount_blocker="$_BD ($_MP) - sending SIG$SIGN to [$pid] $(realpath /proc/$pid/exe):"
					for umount_file in $umount_files; do
						udev_log 0 "$umount_blocker $umount_file"
					done
					kill -$SIGN $pid >/dev/null 2>&1
				done
				sync
				umount $_BD >/dev/null 2>&1
			done

			REAL__do_umount_locked $*
			_RV=$?
		fi
	fi

	if grep -q "^$_BD " /proc/mounts; then
		udev_log 0 "$_BD ($_MP) - mounting read-only"                        # readonly
		mount $_BD -o remount,ro

		udev_log 0 "$_BD ($_MP) - forcing unmount"                           # force
		umount -f $_BD

		REAL__do_umount_locked $*
		_RV=$?
	fi

	if grep -q "^$_BD " /proc/mounts; then                                       # logging
		local pid umount_file umount_files umount_blocker
		for pid in $(busybox ps | sed 's/^ *//g;s/ .*//g'); do  
			umount_files="$(realpath /proc/$pid/cwd /proc/$pid/exe /proc/$pid/fd/* 2>/dev/null | grep -E "$_MP|$DUMP")"
			[ -z "$umount_files" ] && continue
			umount_blocker="$_BD ($_MP) - still used by $(realpath /proc/$pid/exe):"
			for umount_file in $umount_files; do
				udev_log 1 "$umount_blocker $umount_file"
			done
		done
		eventadd 135 "Partition $_MP ($_BD)"
		udev_log 1 "$_BD ($_MP) - could not be unmounted"
	else                                                                         # umounted
		eventadd 141 "Partition $_MP ($_BD)"
		udev_log 0 "$_BD ($_MP) - unmounted successfully"
		rmdir "$_MP" "$DUMP" 2>/dev/null
		_RV=0
	fi

	return $_RV
}


