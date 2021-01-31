#/bin/bash
SCRIPT="$(readlink -f $0)"
PARENT="$(dirname ${SCRIPT%/*})"
[ "$1" == "f" ] && f=f && shift
[ "$#" == "0" ] && sed -rn 's/^.\t*default "(Serial=.*)" *if .*/\1/p' "$PARENT/config/mod/download.in" | while read line; do $SCRIPT $f "$line"; done && sleep 7 && exit 0

FREETZ_DL_SOURCE_JUIS="$*"
JUIS_FAKE="$(hexdump -n3 -e '/1 "%02X"' /dev/random)"
JUIS_SER="$(hexdump -n3 -e '/1 "%02X"' /dev/random)"
JUIS_REV="$(echo $(( RANDOM % 10 ))$(( RANDOM % 10 ))$(( RANDOM % 10 )))"
JUIS_LNG=de && JUIS_OEM=avm
#[ "${FREETZ_TYPE_LANG_DE}" == "y" ] && JUIS_LNG=de && JUIS_OEM=avm
#[ "${FREETZ_TYPE_LANG_DE}" != "y" ] && JUIS_LNG=en && JUIS_OEM=avme
JUIS_TXT=$(echo $FREETZ_DL_SOURCE_JUIS | sed "s/%FAKE%/$JUIS_FAKE/;s/%SER%/$JUIS_SER/;s/%REV%/$JUIS_REV/;s/%LNG%/$JUIS_LNG/;s/%OEM%/$JUIS_OEM/")
[ "$f" != "f" ] && echo -e "\n$JUIS_TXT"
#                        tools/yf/juis/juis_check --debug -i $JUIS_TXT
[ "$f" != "f" ] &&       tools/yf/juis/juis_check         -i $JUIS_TXT 2>&1 | grep -vE "^DelayDownload|Neue Version gefunden"
[ "$f" == "f" ] && nohup tools/yf/juis/juis_check         -i $JUIS_TXT 2>&1 | grep -vE "^DelayDownload|Neue Version gefunden" &

exit 0

