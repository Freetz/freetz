# load the desired skin from cookie if present or MOD_SKIN
case $HTTP_COOKIE in
	# (very rough cookie parsing at the moment)
	*skin=*) skin=${HTTP_COOKIE##*skin=}; skin=${skin%%[^A-Za-z0-9_]*} ;;
	*) skin=$MOD_SKIN ;;
esac
[ -r "/usr/share/skin/$skin/skin.sh" ] || skin=legacy
source "/usr/share/skin/$skin/skin.sh"
