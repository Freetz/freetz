. /mod/etc/conf/mod.cfg

sec_level=1
[ -r /tmp/flash/security ] && mv /tmp/flash/security /tmp/flash/mod/security
[ -r /tmp/flash/mod/security ] && let sec_level=$(cat /tmp/flash/mod/security)

_cgi_id() {
	case $1 in
		*[/]*) echo "$1" | sed "s#/#:#g" ;;
		*) echo "$1" ;;
	esac
}

include() {
    source /usr/lib/mod/cgi/$1.sh
}
include html
include form
include links
include menu
include page
include stat_bar
include error
include request
include validation

#
# Load the desired skin (very rough cookie parsing at the moment)
#
case $HTTP_COOKIE in
	*skin=*) skin=${HTTP_COOKIE##*skin=}; skin=${skin%%[^A-Za-z0-9_]*} ;;
	*) skin=legacy ;;
esac
[ -r "/usr/share/skin/$skin/skin.sh" ] || skin=legacy
source "/usr/share/skin/$skin/skin.sh"
