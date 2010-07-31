highlight() {
	sed -r '
		s#(failed|already running)\.$#<span class="failure">\1</span>.#
		s#(disabled|inactive|not running)\.#<span class="disabled">\1</span>.#
		s#(enabled| active|done).$#<span class="success">\1</span>.#
		s#(external|inetd)\.$#<span class="foreign">\1</span>.#
	'
}

show_log() {
	local log=$1
	if [ -r "$log" ]; then
		echo "<h1><a href='$SCRIPT_NAME$log'>$log</a></h1>"
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
	    	if [ "$PATH_INFO" = "$1" ]; then
		    	show_log "$1"
		fi
	}
fi

do_log /var/log/mod_load.log
do_log /var/log/mod_net.log
do_log /var/log/mod_voip.log
do_log /var/log/mod.log
do_log /var/log/mod_swap.log
[ -r /etc/external.pkg ] && do_log /var/log/external.log
