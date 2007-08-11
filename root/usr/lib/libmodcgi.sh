let _cgi_width=730
if [ "$cgi_width" -gt 0 ]; then let _cgi_width="$cgi_width"; fi
let _cgi_total_width="$_cgi_width+40"

_cgi_menu() {
cat << EOF
<div class="menu">
<div id="status"><a href="/cgi-bin/status.cgi">Status</a></div>
<div id="logs" class="su"><a href="/cgi-bin/logs.cgi">Logs</a></div>
<div id="daemons"><a href="/cgi-bin/daemons.cgi">$(lang de:"Dienste" en:"Services")</a></div>
<div id="settings"><a href="/cgi-bin/settings.cgi">$(lang de:"Einstellungen" en:"Settings")</a></div>
EOF

if [ "$1" = "settings" -a -r "/mod/etc/reg/file.reg" ]; then
	cat /mod/etc/reg/file.reg | while IFS='|' read -r id title sec def; do
		echo "<div id=\"file_$id\" class=\"su\"><a href=\"/cgi-bin/file.cgi?id=$id\">$title</a></div>"
	done
fi

cat << EOF
<div id="packages"><a href="/cgi-bin/packages.cgi">$(lang de:"Pakete" en:"Packages")</a></div>
EOF

if [ "$1" != "settings" -a -r "/mod/etc/reg/cgi.reg" ]; then
	cat /mod/etc/reg/cgi.reg | while IFS='|' read -r pkg title; do
		echo "<div id=\"pkg_$pkg\" class=\"su\"><a href=\"/cgi-bin/pkgconf.cgi?pkg=$pkg\">$title</a></div>"
	done
fi

cat << EOF
<div id="extras"><a href="/cgi-bin/extras.cgi">Extras</a></div>
</div>
EOF
}

cgi_begin() {
cat << EOF
Content-type: text/html; charset=iso-8859-1

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta http-equiv="Content-Language" content="$(lang de:"de" en:"en")">
<meta http-equiv="Expires" content="0">
<meta http-equiv="Pragma" content="no-cache">
<title>DS-MOD - $1</title>
<link rel="stylesheet" type="text/css" href="/style.css">
EOF

if [ -n "$2" ]; then
cat << EOF
<style type="text/css">
<!--
#$2 $(cat /usr/share/style.sel)
-->
</style>
EOF
fi

cat << EOF
</head>
<body>
<table border="0" cellspacing="0" cellpadding="0" align="center" width="$_cgi_total_width">
<tr>
<td width="20"><img src="/images/edge_lt.png" width="20" height="40" border="0" alt=""></td>
<td width="$_cgi_width" id="edgetop"><div class="version">$(cat /etc/.subversion)</div><div class="title">DS-MOD - <span style="font-style: italic;">$1</span></div></td>
<td width="20"><img src="/images/edge_rt.png" width="20" height="40" border="0" alt=""></td>
</tr>
<tr>
<td width="20" id="edgeleft"></td>
<td width="$_cgi_width" id="content">
EOF

if [ -n "$2" ]; then
	case "$2" in
		settings|file_*) sub='settings' ;;
		*) sub='packages' ;;
	esac

	[ -e "/mod/var/cache/menu_$sub" ] || _cgi_menu $sub > /mod/var/cache/menu_$sub
	cat /mod/var/cache/menu_$sub
fi
}

cgi_end() {
cat << EOF
</td>
<td width="20" id="edgeright"></td>
</tr>
<tr>
<td width="20"><img src="/images/edge_lb.png" width="20" height="20" border="0" alt=""></td>
<td width="$_cgi_width" id="edgebottom"><div class="opt">$(lang de:"optimiert f&uuml;r Mozilla Firefox" en:"optimized for Mozilla Firefox")</div></td>
<td width="20"><img src="/images/edge_rb.png" width="20" height="20" border="0" alt=""></td>
</tr>
</table>
</body>
</html>
EOF
}

sec_begin() {
cat << EOF
<div class="body">
<fieldset>
<legend>$1</legend>
EOF
}

sec_end() {
cat << EOF
</fieldset>
</div>
EOF
}
