
let _width=$_cgi_width-230

show_log() {
	local log=$1
	if [ -r "$log" ]; then
		echo "<h1>$log</h1>"
		echo '<pre style="width: '$_width'px; overflow: auto; max-height: 200px;">'
		html < "$log"
		echo '</pre>'
	fi
}

show_log /var/log/mod_load.log
show_log /var/log/mod_net.log
show_log /var/log/mod_voip.log
show_log /var/log/mod.log
[ -r /etc/external.pkg ] && show_log /var/log/external.log
