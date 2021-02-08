cgi_begin 'juis_check ...'
echo '<pre>'
echo 'Please wait ...'
echo

do__juis_check() {
	local MAJOR VER REV PUBLIC TMP MAC NAME HWREV OEM LANG COUNTRY ANNEX FLAG NONCE JUIS

	MAJOR="$(sed -nr 's/^firmware_info[ \t]*([^\.]*).*/\1/p' /proc/sys/urlader/environment)"

	VER="$(sed -n 's/^firmware_info[ \t]*[^\.]*.//p' /proc/sys/urlader/environment)"
	REV="$(/etc/version --project)"
	[ -z "$REV" ] && REV="$(/etc/version -vsub | sed 's/-//')"
	[ -z "$REV" ] && REV="0"
	echo "Local version: $MAJOR.$VER-$REV"

	case "$(sed -n 's/"//g;s/.* CONFIG_BUILDTYPE=//p' /etc/init.d/rc.conf 2>/dev/null)" in
		1000) PUBLIC='0' ;;
		1001) PUBLIC='1' ;;
		*) PUBLIC='2' ;;
	esac

	if [ "$PUBLIC" == "2" ]; then
		VER="$(echo ${VER} | sed 's/\.//;s/^0*//')"
		VER="$(echo 0$(( $VER - 1 )) | sed -r 's/.*(..)(..)$/\1.\2/')"
	fi
	if [ "$REV" -gt 0 2>/dev/null ]; then
		while [ "${#TMP}" != "3" ]; do TMP="$(echo $(( RANDOM % 10 ))$(( RANDOM % 10 ))$(( RANDOM % 10 )) | sed 's/[^0-9]//')"; done
		REV="$(( ${REV:0:$(( ${#REV} - 3 ))} - 1 ))$TMP"
	fi
	echo "Using version: $MAJOR.$VER-$REV"

	while [ "${#MAC}" != "6" ]; do MAC="$(hexdump -n3 -e '/1 "%02X"' /dev/urandom | sed 's/[^0-9A-F]//')"; done
	MAC="$MAC$(sed -nr 's/^maca[ \t]*(..):(..):(..):.*/\1\2\3/p' /proc/sys/urlader/environment)"

	NAME="$(grep ' _PRODUKT_NAME=' /etc/init.d/rc.init 2>/dev/null | sed -rn 's/^HW=[^a][^ ]* OEM=all _PRODUKT_NAME=//p' | sed 's/\#/ /g')"
	[ -z "$NAME" ] && NAME="$(sed -rn 's/^export CONFIG_PRODUKT_NAME=\"?([^\"]*)\"?$/\1/p' /etc/init.d/rc.conf | head -n1)"
	NAME="${NAME// /$(printf '\342\200\212')}"

	HWREV="$(sed -n 's/^HWRevision[ \t]*//p' /proc/sys/urlader/environment)"

	OEM="$(sed -n 's/^firmware_version[ \t]*//p' /proc/sys/urlader/environment)"
	[ "$OEM" == "avm" ] && LANG='de' && COUNTRY='049'
	[ "$OEM" != "avm" ] && LANG='en' && COUNTRY='99'

	ANNEX="$(sed -n 's/^annex[ \t]*//p' /proc/sys/urlader/environment)"
	[ "$ANNEX" == "Kabel" ] && FLAG='cable_retail' || FLAG='empty'

	NONCE="$(dd if=/dev/urandom bs=16 count=1 2>/dev/null | base64)"

	JUIS="Version=$MAJOR.$VER-$REV Serial=$MAC Name=$NAME HW=$HWREV OEM=$OEM Lang=$LANG Country=$COUNTRY Annex=$ANNEX Flag=$FLAG Public=$PUBLIC Nonce=$NONCE"
	echo
#	echo -e "JUIS: $JUIS\n"
#	juis_check -d -n -i -s /tmp/.juis_check $JUIS 2>&1            | html | sed 's/\[[0-9]*m//g;s/.*juis_check.: //'
	juis_check    -n -i -s /tmp/.juis_check $JUIS 2>&1 >/dev/null | html | sed 's/\[[0-9]*m//g;s/.*juis_check.: //'
	touch /tmp/.juis_check
}
do__juis_check

echo
echo "done."
echo '</pre>'
back_button mod system
cgi_end

