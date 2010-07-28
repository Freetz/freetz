
let _width=$_cgi_width-230

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
		echo "<h1>$log</h1>"
		echo '<pre class="log" style="width: '$_width'px; max-height: 350px;">'
		html < "$log" | highlight
		echo '</pre>'
	fi
}

show_log /var/log/mod_load.log
show_log /var/log/mod_net.log
show_log /var/log/mod_voip.log
show_log /var/log/mod.log
[ -r /etc/external.pkg ] && show_log /var/log/external.log
