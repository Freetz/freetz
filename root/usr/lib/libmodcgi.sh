. /mod/etc/conf/mod.cfg

html_cat() {
	local IFS= line
	while read -r line; do
		echo "$line"
	done
} 

# HTML-escape pieces of texts, large ones in a streaming manner
# (large_text | html; html "$small_value")
html() {
	if [ $# -eq 0 ]; then
		sed -e '
		    s/&/\&amp;/g
		    s/</\&lt;/g
		    s/>/\&gt;/g
		    s/'\''/\&#39;/g
		    s/"/\&quot;/g
		'
	else
		httpd -e "$*"
	fi
}

_cgi_menu() {
html_cat << EOF
<div class="menu">
<div id="status"><a href="/cgi-bin/status.cgi">Status</a></div>
EOF

if [ "$1" = "status" ]; then
	if [ -r /mod/etc/reg/status.reg ]; then
		cat /mod/etc/reg/status.reg | while IFS='|' read -r pkg title cgi; do
			echo "<div id=\"status_$(echo $cgi | sed -e "s/\//__/")\" class=\"su\"><a href=\"/cgi-bin/pkgstatus.cgi?pkg=$pkg&amp;cgi=$cgi\">$title</a></div>"
		done
	fi
fi

html_cat << EOF
<div id="daemons"><a href="/cgi-bin/daemons.cgi">$(lang de:"Dienste" en:"Services")</a></div>
<div id="settings"><a href="/cgi-bin/settings.cgi">$(lang de:"Einstellungen" en:"Settings")</a></div>
EOF

if [ "$1" = "settings" -a -r /mod/etc/reg/file.reg ]; then
	cat /mod/etc/reg/file.reg | while IFS='|' read -r id title sec def; do
		echo "<div id=\"file_$id\" class=\"su\"><a href=\"/cgi-bin/file.cgi?id=$id\">$title</a></div>"
	done
fi

html_cat << EOF
<div id="packages"><a href="/cgi-bin/packages.cgi">$(lang de:"Pakete" en:"Packages")</a></div>
EOF

if [ "$1" != "settings" -a "$1" != "status" -a -r /mod/etc/reg/cgi.reg ]; then
	cat /mod/etc/reg/cgi.reg | while IFS='|' read -r pkg title; do
		echo "<div id=\"pkg_$pkg\" class=\"su\"><a href=\"/cgi-bin/pkgconf.cgi?pkg=$pkg\">$title</a></div>"
	done
fi

html_cat << EOF
<div id="extras"><a href="/cgi-bin/extras.cgi">Extras</a></div>
<div id="backup_restore"><a href="/cgi-bin/backup_restore.cgi">$(lang de:"Sichern/Wiederherstellen" en:"Backup/restore")</a></div>
<div id="rudi_shell"><a href="/cgi-bin/rudi_shell.cgi" target="_blank">$(lang de:"Rudi-Shell" en:"Rudi shell")</a></div>
</div>
EOF
}

cgi_begin() {
html_cat << EOF
Content-type: text/html; charset=iso-8859-1

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta http-equiv="Content-Language" content="de">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Pragma" content="no-cache">
<title>Freetz - $1</title>
<link rel="stylesheet" type="text/css" href="/style.css">
EOF

# custom style for fieldset and div.body
if [ ! "$_cgi_width" ]; then
	let _cgi_width=$MOD_CGI_WIDTH
fi
export _cgi_width
let _cgi_total_width="$_cgi_width+40"
let _usr_style="$_cgi_width-230"
echo '<style type="text/css">'
echo "fieldset { margin: 0px; margin-top: 10px; margin-bottom: 10px; padding: 10px; width: "$_usr_style"px;}"
echo "div.body { width: "$_usr_style"px; }"
echo "</style>"

if [ -n "$2" ]; then
html_cat << EOF
<style type="text/css">
<!--
#$2 $(cat /usr/share/style.sel)
-->
</style>
EOF
fi

html_cat << EOF
</head>
<body>
<table border="0" cellspacing="0" cellpadding="0" align="center" width="$_cgi_total_width">
<tr>
<td width="20"><img src="/images/edge_lt.png" width="20" height="40" border="0" alt=""></td>
<td width="$_cgi_width" id="edgetop"><div class="version">$(cat /etc/.subversion)</div><div class="title">Freetz <a href="/cgi-bin/about.cgi" target="_blank" style="color: white;">-</a> <span style="font-style: italic;">$1</span></div></td>
<td width="20"><img src="/images/edge_rt.png" width="20" height="40" border="0" alt=""></td>
</tr>
<tr>
<td width="20" id="edgeleft"></td>
<td width="$_cgi_width" id="content">
EOF

if [ -n "$2" ]; then
	case "$2" in
		settings|file_*) sub='settings' ;;
		status*) sub='status' ;;
		*) sub='packages' ;;
	esac

	[ -e "/mod/var/cache/menu_$sub" ] || _cgi_menu "$sub" > "/mod/var/cache/menu_$sub"
	cat "/mod/var/cache/menu_$sub"
fi
}

cgi_end() {
html_cat << EOF
</td>
<td width="20" id="edgeright"></td>
</tr>
<tr>
<td width="20"><img src="/images/edge_lb.png" width="20" height="20" border="0" alt=""></td>
<td width="$_cgi_width" id="edgebottom"><div class="opt">$(lang de:"optimiert f&uuml;r" en:"optimised for") Mozilla Firefox</div></td>
<td width="20"><img src="/images/edge_rb.png" width="20" height="20" border="0" alt=""></td>
</tr>
</table>
</body>
</html>
EOF
}

sec_begin() {
html_cat << EOF
<div class="body">
<fieldset>
<legend>$1</legend>
EOF
}

sec_end() {
html_cat << EOF
</fieldset>
</div>
EOF
}
