skin_head() {
	local title=$1 id=$2
	cat << EOF
<title>Freetz&nbsp;&#64;$(hostname -s|html)&nbsp;&ndash; $title</title>
<link rel="stylesheet" type="text/css" href="/style/cuma/base.css">
<link rel="stylesheet" type="text/css" href="/style/colorscheme.css">
EOF
	_cgi_print_extra_styles

	# The width of the whole cgi: There are 40px border (left+right)
	# and 225px for the menu area.
	let _cgi_total_width=_cgi_width+40+225

	# If there is no menu, we make the space available to the content.
	[ -z "$id" ] && let _cgi_width+=225
}

skin_body_begin() {
	local title=$1 id=$2
	local help=""
	if [ -n "$_CGI_HELP" ]; then
		help="&nbsp;<span class='help'>(<a href='$(html "$_CGI_HELP")' target='_blank'>$(lang de:"Hilfe" en:"Help")</a>)</span>"
	fi
	cat << EOF
<table id="edge" border="0" cellspacing="0" cellpadding="0" width="$_cgi_total_width">
<colgroup><col width="20"><col width="*"><col width="20"></colgroup>
<tr>
<td id="edge-top-left"></td>
<td id="edge-top">
<div class="version">$(html < /etc/.freetz-version)</div>
<div class="titlebar"><a href="http://freetz.org/" target="_blank" class="logo">Freetz</a>&nbsp;&#64;<a href="/cgi-bin/avm" target="_blank">$(hostname -s|html)</a>&nbsp;<a href="/cgi-bin/about.cgi" target="_blank">&ndash;</a>&nbsp;<span class="title">$title</span>$help &nbsp; &nbsp; $([ "$isauth" = 1 ] && echo "<small>Session timeout: $(date -d @$(( $MOD_HTTPD_SESSIONTIMEOUT + $(date +%s) )) +'%H:%M:%S')</small>") </div>
</td>
<td id="edge-top-right"></td>
</tr>
<tr>
<td id="edge-left"></td>
<td id="container">
EOF
	[ -n "$id" ] && _cgi_print_menu "$id"
	echo "<div id='content'>"
}

skin_body_end() {
	cat << EOF
</div>
</td>
<td id="edge-right"></td>
</tr>
<tr>
<td id="edge-bottom-left"></td>
<td id="edge-bottom"></td>
<td id="edge-bottom-right"></td>
</tr>
</table>
<div id="footer">
<span class="datetime" title="$(lang de:"Systemzeit des Routers" en:"Router's system time")">$(date +'$(lang de:"%d.%m.%Y" en:"%m/%d/%Y") %H:%M')</span>&nbsp;&ndash;
<span class="uptime" title="Uptime">$(uptime | sed -r 's/.*(up.*), *load.*/\1/')</span>&nbsp;&ndash;
<span class="opt">$(lang de:"optimiert f&uuml;r" en:"optimized for") Mozilla Firefox</span>
</div>
EOF
}

skin_sec_begin() {
	# A fieldset adds a padding of 10px to the left and right, which is
	# space the content cannot utilize. By altering _cgi_width, we somehow
	# violate the rule "cgi application can use _cgi_width pixels just as
	# requested in 'cgi --width=1234'", but sec_begin is optional! If the
	# app really needs 1234px, then it should not use sec_begin() or it
	# will live with the fact that we take away some pixels.
	cgi_width_alter -20
	cat << EOF
<fieldset>
<legend>$1</legend>
EOF
}

skin_sec_end() {
	cgi_width_alter 20
	cat << EOF
</fieldset>
EOF
}
