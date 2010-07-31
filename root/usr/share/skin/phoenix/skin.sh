_cgi_head() {
local title=$1 id=$2
cat << EOF
<title>Freetz&nbsp;&ndash; $title [phoenix]</title>
<link rel="stylesheet" type="text/css" href="/style/phoenix/base.css">
<link rel="stylesheet" type="text/css" href="/style/colorscheme.css">
EOF

# custom style for fieldset and div.body
if [ ! "$_cgi_width" ]; then
	let _cgi_width=$MOD_CGI_WIDTH
fi
export _cgi_width
let _cgi_total_width="$_cgi_width+40"
let _usr_style="$_cgi_width-230"
cat << EOF
<style type="text/css">
<!--
fieldset {
	margin: 0px;
	margin-top: 10px;
	margin-bottom: 10px;
	padding: 10px;
	width: ${_usr_style}px;
}
div.body {
	width: ${_usr_style}px;
}
-->
</style>
EOF
}

_cgi_body_begin() {
local title=$1 id=$2
cat << EOF
<div id="header">
<span class="version">$(html < /etc/.freetz-version)</span>
<h1><a href="/cgi-bin/index.cgi" class="logo">Freetz</a>&nbsp;<a href="/cgi-bin/about.cgi" target="_blank">&ndash;</a> <span class="title">$title</span></h1>
</div>
<div id="container">
EOF

[ -n "$id" ] && _cgi_print_menu "$id"
echo "<div id='content'>"
}

_cgi_body_end() {
cat << EOF
</div>
<div id="footer">
<span class="datetime" title="$(lang de:"Systemzeit des Routers" en:"Router's system time")">$(date +'$(lang de:"%d.%m.%Y" en:"%m/%d/%Y") %H:%M')</span>&nbsp;&ndash;
<span class="uptime" title="Uptime">$(uptime | sed -r 's/.*(up.*), load.*/\1/')</span>&nbsp;&ndash;
<span class="opt">$(lang de:"optimiert f&uuml;r" en:"optimised for") Mozilla Firefox</span>
</div>
EOF
}

sec_begin() {
cat << EOF
<div class="section">
<h1>$1</h1>
EOF
}

sec_end() {
cat << EOF
</div>
EOF
}

_cgi_print_menu() {
	local id=$1 sub= act_sub=
	case $id in
		settings|file:*) act_sub=settings ;;
		status*) act_sub=status ;;
		system|avmwif_*|rudi_*|firmware_*|backup_*) act_sub=system ;;
		packages|pkg:*) act_sub=packages ;;
	esac
	: ${sub:=$act_sub}

	_cgi_cached "menu_$sub" _cgi_menu "$sub" | _cgi_mark_active "$act_sub|$id"
}
