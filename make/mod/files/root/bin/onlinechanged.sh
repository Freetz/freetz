#!/bin/sh
PID_FILE=/var/run/onlinechanged
OC_STATE="$1"

# multid is preloaded with libmultid
unset LD_PRELOAD

# parameter -e: additional new-line at line end
log() {
	local addline=""
	while [ "$1" == "-e" ]; do
		addline="\n"
		shift
	done
	echo -e "$(date '+%Y-%m-%d %H:%M:%S') [$$]: [$OC_STATE] $*$addline" >>/var/log/onlinechanged.log
	echo "ONLINECHANGED[$$]: [$OC_STATE] $*" >/dev/console
	logger -t ONLINECHANGED[$$] "[$OC_STATE] $*"
}

# semaphore older than 3 min -> kill waiting sibling scripts (not during startup)
if [ -e /tmp/.modstarted -a "$(find $PID_FILE -prune -mmin +3 2>/dev/null)" == "$PID_FILE" ]; then
	for pid in $(pidof onlinechanged.sh | sed "s/ \?$$//"); do
		log "killing old process #$pid"
		kill $pid
	done
	rm -rf $PID_FILE 2>/dev/null
fi

# shutdown: do nothing
if [ -e /var/run/shutdown ]; then
	log "disabled"
	exit 0
fi

if [ -e $PID_FILE ]; then
	if [ ! -e /tmp/.modstarted ]; then
		# startup: quit if another onlinechanged is yet running
		[ "$OC_STATE" == "offline" ] && rm -rf $PID_FILE 2>/dev/null
		log "rejected"
		exit 0
	else
		# no startup/shutdown: wait for other onlinechanged to finish
		log "waiting"
		while [ -e $PID_FILE ]; do
			sleep 1
		done
	fi
fi

touch $PID_FILE

# startup: wait for rc.mod, abort if status changes to "offline"
if [ ! -e /tmp/.modstarted ]; then
	log "sleeping"
	while [ ! -e /tmp/.modstarted ]; do
		if [ ! -e $PID_FILE ]; then
			log "aborted"
			exit 0
		fi
		sleep 1
	done
fi

# execute onlinechanged scripts
eventadd 1 "Running onlinechanged: $OC_STATE"
log "approved"
for i in /etc/onlinechanged/* /mod/etc/onlinechanged/* /tmp/onlinechanged/* /tmp/flash/onlinechanged/*; do
	[ ! -s "$i" ] && continue
	log "executing $i"
	sh "$i" "$@" 2>&1 | while read line; do [ -n "$line" ] && log " * $line"; done
done
log -e "finished"

rm -rf $PID_FILE 2>/dev/null
