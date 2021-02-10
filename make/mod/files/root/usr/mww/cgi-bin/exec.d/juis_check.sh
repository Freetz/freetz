cgi_begin 'juis_check ...'
echo '<pre>'
echo 'Please wait ...'
echo

[ -r /etc/options.cfg ] && . /etc/options.cfg
do__juis_check() {
	local MAJOR VER REV BUILDTYPE TMP MAC NONCE JUIS

	MAJOR="$(sed -nr 's/^firmware_info[ \t]*([^\.]*).*/\1/p' /proc/sys/urlader/environment)"
	VER="$(sed -n 's/^firmware_info[ \t]*[^\.]*.//p' /proc/sys/urlader/environment)"
	REV="$(/etc/version --project)"
	[ -z "$REV" ] && REV="$(/etc/version -vsub | sed 's/-//')"
	[ -z "$REV" ] && REV="0"
	echo "Local version: $MAJOR.$VER-$REV"

	BUILDTYPE="$(sed -n 's/"//g;s/.* CONFIG_BUILDTYPE=//p' /etc/init.d/rc.conf 2>/dev/null)"
	[ -z "$BUILDTYPE" ] && BUILDTYPE='1'
	if [ "$BUILDTYPE" != "1" -o "$FREETZ_TYPE_ALIEN_HARDWARE" == "y" ]; then
		[ "$FREETZ_TYPE_ALIEN_HARDWARE" == "y" ] && TMP='30' || TMP='1'
		VER="$(echo ${VER} | sed 's/\.//;s/^0*//')"
		VER="$(echo 0$(( $VER - $TMP )) | sed -r 's/.*(..)(..)$/\1.\2/')"
	fi
	if [ "$REV" -gt 0 2>/dev/null ]; then
		while [ "${#TMP}" != "3" ]; do TMP="$(echo $(( RANDOM % 10 ))$(( RANDOM % 10 ))$(( RANDOM % 10 )) | sed 's/[^0-9]//')"; done
		REV="$(( ${REV:0:$(( ${#REV} - 3 ))} - 1 ))$TMP"
	fi
	echo "Using version: $MAJOR.$VER-$REV"

	while [ "${#MAC}" != "6" ]; do MAC="$(hexdump -n3 -e '/1 "%02X"' /dev/urandom | sed 's/[^0-9A-F]//')"; done
	MAC="$MAC$(sed -nr 's/^maca[ \t]*(..):(..):(..):.*/\1\2\3/p' /proc/sys/urlader/environment)"

	NONCE="$(dd if=/dev/urandom bs=16 count=1 2>/dev/null | base64)"

	JUIS="Version=$MAJOR.$VER-$REV Serial=$MAC Buildtype=$BUILDTYPE Nonce=$NONCE"
	echo
	juis_check -d -i -l -s /tmp/.juis_check $JUIS 2>&1            | sed -r 's/>(<[^\/])/>\n\t\1/g'           | html
#	juis_check -n -i -l -s /tmp/.juis_check $JUIS 2>&1 >/dev/null | sed 's/\[[0-9]*m//g;s/.*juis_check.: //' | html
	touch /tmp/.juis_check
}
do__juis_check

echo
echo "done."
echo '</pre>'
back_button mod system
cgi_end

