cgi_begin 'juis_check ...'
echo '<pre>'
echo 'Please wait ...'
echo

do__juis_check() {
	local TMP VER REV

	VER="$(/etc/version -v)"
	REV="$(/etc/version -vsub | sed 's/-//')"
	[ -z "$REV" ] && REV="$(/etc/version --project)"
	echo "Local version: $VER${REV:+-$REV}"

	if [ "$REV" -gt 0 2>/dev/null ]; then
		while [ "${#TMP}" != "3" ]; do TMP="$(echo $(( RANDOM % 10 ))$(( RANDOM % 10 ))$(( RANDOM % 10 )) | sed 's/[^0-9]//')"; done
		REV="-$(( ${REV:0:-3} - 1 ))$TMP"
	fi
	if [ -z "$(. /var/env.cache ; echo $CONFIG_LABOR_ID_NAME)" ]; then
		TMP="$(echo ${VER#*.} | sed 's/\.//;s/^0//')"
		TMP="$(echo 0$(( $TMP - 1 )) | sed -r 's/.*(..)(..)$/\1.\2/')"
		VER="${VER%%.*}.$TMP"
	fi
	echo "Using version: $VER$REV"

	echo
	juis_check    -n -i -l -s /tmp/.juis_check Version=$VER$REV 2>&1 >/dev/null | html | sed 's/\[[0-9]*m//g;s/.*juis_check.: //'
#	juis_check -d -n -i -l -s /tmp/.juis_check Version=$VER$REV 2>&1            | html | sed 's/\[[0-9]*m//g;s/.*juis_check.: //'
	touch /tmp/.juis_check
}
do__juis_check

echo
echo "done."
echo '</pre>'
back_button mod system
cgi_end

