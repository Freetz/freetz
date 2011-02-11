#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/mod/sbin:/mod/bin:/mod/usr/sbin:/mod/usr/bin
. /usr/lib/libmodcgi.sh

exec 1> /tmp/ex_update.log 2>&1
indent() {
    sed 's/^/  /' | html
}

EXTERNAL_FILE=$1
echo "[external] Processing file $EXTERNAL_FILE"
#EXTERNAL_TARGET="$(cat "$EXTERNAL_FILE" | tar -xO ./.external)"
#if [ $? -ne 0 ]; then
#	echo "[external] FAIL, invalid file"
#	exit 1
#fi
EXTERNAL_TARGET=$NAME
echo "[external] Target directory: $EXTERNAL_TARGET"

if [ -d "$EXTERNAL_TARGET" ]; then
	for FILE in `find "$EXTERNAL_TARGET" -type f`; do
		FILES="$FILES `basename $FILE`"
	done	
	echo "[external] killall:$FILES"
	killall "$FILES" 2>/dev/null
	sleep 2
	killall -9 "$FILES" 2>/dev/null
	echo -n "[external] Removing old stuff"
	rm -rf "$EXTERNAL_TARGET"
	[ $? -ne 0 ] && echo -n "FAIL"
	echo
fi

echo -n "[external] Unpacking new stuff:"
mkdir -p "$EXTERNAL_TARGET"
tar_log="$(cat "$EXTERNAL_FILE" | tar -C "$EXTERNAL_TARGET" -xv 2>&1)"
[ $? -ne 0 ] && echo -n "FAIL"
echo
echo "$tar_log" | indent
echo "[external] Done."

