. /usr/lib/cgi-bin/mod/modlibcgi

show_log() {
	local log=$1 title
	case $log in
		/var/log/*) title=${log#/var/log/} ;;
		*) title=$log ;;
	esac
	if [ -s "$log" ]; then
		echo "<h1><a href='$SCRIPT_NAME$log'>$title</a></h1>"
		echo "<pre class='log${class+ $class}'>"
		html < "$log" | highlight
		echo '</pre>'
	fi
}

unset class
do_log() {
	show_log "$1"
}

if [ -n "$PATH_INFO" ]; then
	class="full"
	do_log() {
		[ "$PATH_INFO" = "$1" ] && show_log "$1"
	}
fi

do_log /var/log/mod_load.log
do_log /var/log/mod_net.log
do_log /var/log/mod_voip.log
do_log /var/log/mod.log
do_log /var/log/mod_swap.log
do_log /var/log/rc_custom.log
do_log /var/log/onlinechanged.log
do_log /var/log/external.log
do_log /var/log/mod_mount.log
