_cgi_head() {
local title=$1 id=$2
cat << EOF
<title>Freetz&nbsp;&ndash; $title</title>
<link rel="stylesheet" type="text/css" href="/style/base.css">
<link rel="stylesheet" type="text/css" href="/style/colorscheme.css">
EOF

# custom width
: ${_cgi_width:=$MOD_CGI_WIDTH}
export _cgi_width
let _cgi_total_width=_cgi_width+40
}

_cgi_body_begin() {
local title=$1 id=$2
cat << EOF
<table id="edge" border="0" cellspacing="0" cellpadding="0" width="$_cgi_total_width">
<colgroup><col width="20"><col width="*"><col width="20"></colgroup>
<tr>
<td id="edge-top-left"></td>
<td id="edge-top">
<div class="version">$(html < /etc/.freetz-version)</div>
<div class="titlebar"><a href="/cgi-bin/index.cgi" class="logo">Freetz</a>&nbsp;<a href="/cgi-bin/about.cgi" target="_blank">&ndash;</a> <span class="title">$title</span></div>
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

_cgi_body_end() {
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
<span class="uptime" title="Uptime">$(uptime | sed -r 's/.*(up.*), load.*/\1/')</span>&nbsp;&ndash;
<span class="opt">$(lang de:"optimiert f&uuml;r" en:"optimised for") Mozilla Firefox</span>
</div>
EOF
}

sec_begin() {
cat << EOF
<fieldset>
<legend>$1</legend>
EOF
}

sec_end() {
cat << EOF
</fieldset>
EOF
}
