#!/bin/sh
PID_FILE=/var/run/onlinechanged
OC_STATE="$@"

log() {
	echo "[$$]: [$OC_STATE] $*" >>/var/log/onlinechanged.log
	echo "ONLINECHANGED[$$]: [$OC_STATE] $*" >/dev/console
	logger -t ONLINECHANGED[$$] "[$OC_STATE] $*"
}

# do nothing while shutdown
if [ -e /var/run/shutdown ]; then
	log "disabled"
	exit 0
fi

# quit if another onlinechanged is yet running
if [ -e $PID_FILE ]; then
	[ "$OC_STATE" == "offline" ] && rm -rf $PID_FILE 2>/dev/null
	log "rejected"
	exit 0
fi

# wait for rc.mod, abort if status changes to "offline"
touch $PID_FILE
[ ! -e /tmp/.modstarted ] && log "sleeping"
while [ ! -e /tmp/.modstarted ]; do
	if [ ! -e $PID_FILE ]; then
		log "aborted"
		exit 0
	fi
	sleep 1
done

#execute onlinechanged scripts
eventadd 1 "Running onlinechanged: $OC_STATE"
log "approved"
for i in /etc/onlinechanged/* /tmp/onlinechanged /tmp/flash/onlinechanged/*; do
	[ ! -s "$i" ] && continue
	log "executing $i"
	sh "$i" "$OC_STATE" 2>&1 | while read line; do [ -n "$line" ] && log " * $line"; done
done
log "done"

rm -rf $PID_FILE 2>/dev/null
