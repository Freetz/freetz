#!/bin/sh

[ -r /mod/etc/conf/rrdstats.cfg ] && . /mod/etc/conf/rrdstats.cfg
[ -r /tmp/flash/rrdstats/smarthome.xtras ] && . /tmp/flash/rrdstats/smarthome.xtras
HOST="$RRDSTATS_AHA_AVMHOST"
USER="$RRDSTATS_AHA_AVMUSER"
PASS="$RRDSTATS_AHA_AVMPASS"
PROT="$RRDSTATS_AHA_AVMPROT"
[ "$PROT" == "https" ] && CERT="--no-check-certificate"
FILE=/tmp/.smarthome.sid
NAME=/tmp/flash/rrdstats/smarthome.alias
KIND=/tmp/flash/rrdstats/smarthome.kinds


LOCK_PRE="/tmp/.smarthome.lock."
LOCK_ICK="${LOCK_PRE}$$"
dellock() {
#	rm "$LOCK_ICK"
	[ "$#" -gt 0 ] && exit $1
}
chklock() {
	local LOCK_RUN="$(find "${LOCK_PRE%/*}/" -name "${LOCK_PRE##*/}*" -mmin -1 | head -n1)"
	touch "$LOCK_ICK"
	if [ -n "$LOCK_RUN" ]; then
		local LOCK_CNT=0
		while [ -e "$LOCK_RUN" -a "$LOCK_CNT" -le 9 ]; do
			let LOCK_CNT++
			sleep 1
		done
		if [ -e "$LOCK_RUN" ]; then
			echo "DEADLOCK" 1>&2
			dellock 1
		fi
	fi
}
#chklock


old_sid() { SID="$(cat $FILE 2>/dev/null)" ; }

new_sid() {
	local P1="$(wget $CERT -q "$PROT://$HOST/login_sid.lua" -O - 2>/dev/null | sed 's/.*<Challenge>//;s/<.*//')"
	local P2="$(echo -n -e $(echo -n $P1-$PASS | hexdump -v -e '"\\\x" 1/1 "%02x" "\\\x" "0" "0"' | sed 's!\\\\!\\!g' ) | md5sum | sed 's/ .*//')"
	wget $CERT -q "$PROT://$HOST/login_sid.lua?response=$P1-$P2&username=$USER" -O - 2>/dev/null | sed 's/.*<SID>//;s/<.*//' > $FILE
	old_sid
}

get_web() { REST="$(wget $CERT -q "$PROT://$HOST/webservices/homeautoswitch.lua?sid=$SID&switchcmd=getdevicelistinfos" -O - 2>/dev/null)" ; }

set_web() { REST="$(wget $CERT -q "$PROT://$HOST/webservices/homeautoswitch.lua?sid=$SID&switchcmd=$2&ain=$1" -O - 2>/dev/null)" ; }


readval() { [ "$1" != "${1%</$2>*}" ] && echo -n "$1" | sed -e "s!</$2>.*!!;s!.*<$2>!!" ; }

listgen() {
	echo "$REST" | sed 's,</*devicelist[^>]*>,,g;s!<\(device\|group\) !\n&!g' | grep -v '^$' | while read line; do
		[ "$2" == "NG" ] && [ "${line#<group }" != "$line" ] && continue

		echo -n "$line" | sed 's!.*<\(device\|group\) ! !;s!>.*!!' | sed -e "s!.* identifier=\"!!;s!\" .*!!;s! !!"
		for child in $1; do
			echo -n '|'
			readval "$line" $child
		done
		echo
	done
}


dec2bin() {
	local dec="$1"
	local bin=""
	while [ $dec -gt 0 ] ; do
		bin="$(( $dec % 2 ))$bin"
		dec="$(( $dec / 2 ))"
	done
	while [ ${#bin} -le 18 ]; do bin="0$bin"; done
	echo -n "$bin"
}

min_len() {
	local string="$1"
	while [ ${#string} -lt 27 ]; do string=" $string"; done
	echo -n "$string"
}

readitm() { echo "$1" | sed -e "s!.* $2=\"!!;s!\" .*!!" ; }

raw_out() {
	echo

	echo "$REST" | sed 's,</*devicelist[^>]*>,,g;s!<\(device\|group\) !\n&!g' | grep -v '^$' | while read line; do

		device="$(echo "$line" | sed 's!.*<device ! !;s!>.*!!')"
		for item in manufacturer productname fwversion functionbitmask identifier id; do
			min_len "$item = "
			readitm "$device " $item
			if [ "$item" == "functionbitmask" ]; then
				min_len && dec2bin $(readitm "$device " $item) | sed -re 's/(.*)(....)(....)(....)(....)$/\1 \2 \3 \4 \5 \6\n/;s/0/-/g'
				min_len && echo "SRQ PONM LKJI HGFE DCBA "
			fi
		done

		for child in name  present state mode lock devicelock  power voltage energy  celsius offset  current factor  masterdeviceid members  tist tsoll absenk komfort windowopenactiv  battery batterylow  lastpressedtimestamp; do
			dummy="$(readval "$line" $child)"
			[ -z "$dummy" ] && continue
			if [ "$child" == "lastpressedtimestamp" ]; then
				num=0
				echo "$line" | sed 's/<button /\n&/g' | grep '^<button ' | while read button; do
					echo
					let num++
					for sub in identifier id; do
						min_len "$sub #$num = " && echo "$button" | sed -e "s!.* $sub=\"!!;s!\"[ >].*!!"
					done
					for sub in name lastpressedtimestamp; do
						val="$(readval "$button" $sub)"
						[ -z "$val" ] && continue
						min_len "$sub #$num = " && echo "$val"
						[ "$sub" == "lastpressedtimestamp" ] && min_len && date -d @$val
					done
				done
			else
				min_len "$child = " && echo "$dummy"
			fi
		done

		echo -e "\n"
	done

	min_len && echo "SRQ PONM LKJI HGFE DCBA "
	min_len && echo "||| |||| |||| |||| |||| "
	min_len && echo "||| |||| |||| |||| |||+- Bit  0/A: HANFUN Gerät"
	min_len && echo "||| |||| |||| |||| ||+-- Bit  1/B: ?Unused"
	min_len && echo "||| |||| |||| |||| |+--- Bit  2/C: Lampe"
	min_len && echo "||| |||| |||| |||| +---- Bit  3/D: ?Action"
	min_len && echo "||| |||| |||| ||||      "
	min_len && echo "||| |||| |||| |||+------ Bit  4/E: Alarmsensor"
	min_len && echo "||| |||| |||| ||+------- Bit  5/F: Taster"
	min_len && echo "||| |||| |||| |+-------- Bit  6/G: Heizkörperregler"
	min_len && echo "||| |||| |||| +--------- Bit  7/H: Energiemessgerät"
	min_len && echo "||| |||| ||||           "
	min_len && echo "||| |||| |||+----------- Bit  8/I: Temperatursensor"
	min_len && echo "||| |||| ||+------------ Bit  9/J: Schaltsteckdose"
	min_len && echo "||| |||| |+------------- Bit 10/K: DECT-Repeater"
	min_len && echo "||| |||| +-------------- Bit 11/L: Mikrofon"
	min_len && echo "||| ||||                "
	min_len && echo "||| |||+---------------- Bit 12/M: ?Bundle"
	min_len && echo "||| ||+----------------- Bit 13/N: HANFUN Unit"
	min_len && echo "||| |+------------------ Bit 14/O: ?Template"
	min_len && echo "||| +------------------- Bit 15/P: Schaltbar"
	min_len && echo "|||                     "
	min_len && echo "||+--------------------- Bit 16/Q: Potentiometer"
	min_len && echo "|+---------------------- Bit 17/R: Farbtemperatur"
	min_len && echo "+----------------------- Bit 18/S: Rollladensteuerung"
	echo
}


ali_chk() {
	[ ! -d ${NAME%/*} ] && mkdir -p ${NAME%/*}
	echo "$LIST" | while read line; do
		grep -q "$line$" "$NAME" 2>/dev/null && continue
		local identifier="$(echo "$line" | cut -d '|' -f 1)"
		sed -i "/^$identifier|.*/d" "$NAME" 2>/dev/null
		echo "$line" >> "$NAME"
	done
}
art_chk() {
	[ -r /etc/options.cfg ] && . /etc/options.cfg
	[ ! -d ${KIND%/*} ] && mkdir -p ${KIND%/*}
	echo "$REST" | sed 's,</*devicelist[^>]*>,,g;s!<\(device\|group\) !\n&!g' | grep -v '^$' | while read line; do
		idf="$(echo -n "$line" | sed 's!.*<\(device\|group\) ! !;s!>.*!!' | sed -e "s!.* identifier=\"!!;s!\" .*!!;s! !!")"
		grep -q "$idf|" "$KIND" 2>/dev/null && continue
		if [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ]; then
			fbm="$(echo "$line" | sed 's!.*<\(device\|group\) ! !;s!>.*!!' | sed -e "s!.* functionbitmask=\"!!;s!\" .*!!")"
			art=XXX
			[ "0" != "$(( $fbm & 0x40   ))" ] && art=HKR
			[ "0" != "$(( $fbm & 0x200  ))" ] && art=AKT
			[ "0" != "$(( $fbm & 0x1000 ))" ] && art=GRP
		else
			if [ "${idf%:*}" != "$idf" ]; then
				[ "${idf%-*}" != "$idf" ] && art=GRP || art=PLC
			else
				[ -n "$(readval "$line" lock)" ] && art=AKT || art=HKR
			fi
		fi
		echo "$idf|$art" >> "$KIND"
	done
}


readweb() {
	old_sid
	get_web
	[ -z "$REST" ] && new_sid && get_web
}

ain2label() {
	local label="$(sed -rn "s/^$1\|//p" $NAME 2>/dev/null)"
	[ -n "$label" ] && echo $label || echo $1
}
label2ain() {
	local label="$(sed -rn "s/\|$1//p" $NAME 2>/dev/null)"
	[ -n "$label" ] && echo $label || echo $1
}
docmd() {
	ain="$(label2ain $1)"
	cmd="$2"
	[ "$cmd" == "-1" ] && cmd="toggle"
	[ "$cmd" == "0" ] && cmd="off"
	[ "$cmd" == "1" ] && cmd="on"
	[ "$cmd" == "on" -o "$cmd" == "off" -o "$cmd" == "toggle" ] && cmd="setswitch$cmd"

	cmd="${cmd/\./,}"
	dec="${cmd#*,}"
	if [ "$dec" != "$cmd" ]; then
		cmd="$((${cmd%,*}*2))"
		case "$dec" in
			7|8|9)   dec=2 ;;
			4|5|6)   dec=1 ;;
			1|2|3)   dec=0 ;;
			*|0)     dec=0 ;;
		esac
		cmd="$((cmd+dec))"
	fi

	[ "$cmd" -gt 1 2>/dev/null ] && cmd="sethkrtsoll&param=$cmd"
	echo -n "Executing '$cmd' for '$(ain2label $1)' ... "
	old_sid
	set_web "$ain" "$cmd"
	[ -z "$REST" ] && new_sid && set_web "$1" "$cmd"
	if [ -n "$REST" ]; then
		echo "done."
	#	[ "${cmd#setswitch}" == "$cmd" -o "${cmd#sethkrtsoll&param=}" == "$cmd" ] && echo "$REST"
		return 0
	else
		echo "failed."
		return 1
	fi
}



case $1 in
	a|alias)
		readweb
		LIST="$(listgen 'name')"
		ali_chk
		art_chk
		modsave flash >/dev/null
		;;
	f|fancy)
		readweb
		raw_out
		;;
	s|small)
		readweb
		listgen 'name  power voltage energy  celsius offset  current factor' 'NG' | grep -v '|||||||$'
		;;
	b|battery)
		readweb
		listgen 'name  battery batterylow  present' 'NG' | sed -n 's/|1$//p' | grep -v '||$'
		;;
	m|modus)
		readweb
		listgen 'name  state lock'
		;;
	g|gradc)
		readweb
		listgen 'name  state lock  celsius  tsoll'
		;;
	t|translate)
		[ "$#" != "2" ] && echo "Missing arguments: <ain|name>" 1>&2 && dellock 1
		RESULT=$(cat $NAME 2>/dev/null | while IFS='|' read ain name; do
			[ "$ain" == "$2" ] && echo $name && return
			[ "$name" == "$2" ] && echo $ain && return
		done )
		[ -z "$RESULT" ] && echo $2 && dellock 1
		echo $RESULT
		;;
	d|docmd)
		[ "$#" != "3" ] && echo "Missing arguments: <device> <command>" 1>&2 && dellock 1
		docmd "$2" "$3"
		dellock $?
		;;
	*)
		echo "Usage: $0 <alias|fancy|small|battery|modus|gradc|translate <ain|name>|docmd <device> <command> >" 1>&2
		echo "Commands for Comet Dect, Dect 300+301+302: <16-56> or <8,0-28,0> or <8.0-28.0> or <253|254>" 1>&2
		echo "Commands for Repeater 546E, Dect 200, Dect 201: <off|toggle|on> or <0|-1|1>" 1>&2
		echo "See also: https://freetz-ng.github.io/freetz-ng/make/rrdstats.html#script-ahash" 1>&2
		dellock
		exit 1
		;;
esac

dellock
exit 0

