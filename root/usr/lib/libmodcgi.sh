. /mod/etc/conf/mod.cfg

sec_level=1
[ -r /tmp/flash/security ] && mv /tmp/flash/security /tmp/flash/mod/security
[ -r /tmp/flash/mod/security ] && let sec_level="$(cat /tmp/flash/mod/security)"

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
		case $* in
			*[\&\<\>\'\"]*) httpd -e "$*" ;; #'
			*) echo "$*" ;;
		esac
	fi
}

_cgi_id() {
	case $1 in
		*[/]*) echo "$1" | sed "s#/#__#g" ;;
		*) echo "$1" ;;
	esac
}

_cgi_menu() {
local sub=$1
cat << EOF
<ul class="menu">
<li><a id="status" href="/cgi-bin/status.cgi">Status</a>
EOF

if [ "$sub" = "status" -a -r /mod/etc/reg/status.reg ]; then
    	local pkg title cgi
	echo "<ul>"
	while IFS='|' read -r pkg title cgi; do
		echo "<li><a id='$(_cgi_id "status_$cgi")' href='/cgi-bin/pkgstatus.cgi?cgi=$cgi'>$(html "$title")</a></li>"
	done < /mod/etc/reg/status.reg 
	echo "</ul>"
fi

cat << EOF
</li>
<li><a id="daemons" href="/cgi-bin/daemons.cgi">$(lang de:"Dienste" en:"Services")</a></li>
<li><a id="settings" href="/cgi-bin/settings.cgi">$(lang de:"Einstellungen" en:"Settings")</a>
EOF

if [ "$sub" = "settings" -a -r /mod/etc/reg/file.reg ]; then
    	local id title sec def
	echo "<ul>"
	while IFS='|' read -r id title sec def; do
		echo "<li><a id='$(_cgi_id "file_$id")' href='/cgi-bin/file.cgi?id=$id'>$(html "$title")</a></li>"
	done < /mod/etc/reg/file.reg 
	echo "</ul>"
fi

cat << EOF
</li>
<li><a id="packages" href="/cgi-bin/packages.cgi">$(lang de:"Pakete" en:"Packages")</a>
EOF

if [ "$sub" = "packages" -a -r /mod/etc/reg/cgi.reg ]; then
    	local pkg title
	echo "<ul>"
	while IFS='|' read -r pkg title; do
		echo "<li><a id='$(_cgi_id "pkg_$pkg")' href='/cgi-bin/pkgconf.cgi?pkg=$pkg'>$(html "$title")</a></li>"
	done < /mod/etc/reg/cgi.reg 
	echo "</ul>"
fi

cat << EOF
</li>
<li><a id="extras" href="/cgi-bin/extras.cgi">Extras</a></li>
<li><a id="backup_restore" href="/cgi-bin/backup_restore.cgi">$(lang de:"Sichern/Wiederherstellen" en:"Backup/restore")</a></li>
<li><a id="rudi_shell" href="/cgi-bin/rudi_shell.cgi" target="_blank">$(lang de:"Rudi-Shell" en:"Rudi shell")</a></li>
</ul>
EOF
}

cgi_begin() {
local title=$(html "$1") id=${2:+$(_cgi_id "$2")}
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
<title>Freetz&nbsp;&ndash; $title</title>
<link rel="stylesheet" type="text/css" href="/style/base.css">
<link rel="stylesheet" type="text/css" href="/style/colorscheme.css">
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

if [ -n "$id" ]; then
cat << EOF
<style type="text/css">
<!--
#$id $(cat /usr/share/style.sel)
-->
</style>
EOF
fi

cat << EOF
</head>
<body>
<table id="edge" border="0" cellspacing="0" cellpadding="0" align="center" width="$_cgi_total_width">
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
<td id="content">
EOF

local sub
if [ -n "$id" ]; then
	case $id in
		settings|file_*) sub='settings' ;;
		status*) sub='status' ;;
		*) sub='packages' ;;
	esac

	[ -e "/mod/var/cache/menu_$sub" ] || _cgi_menu "$sub" > "/mod/var/cache/menu_$sub"
	cat "/mod/var/cache/menu_$sub"
fi
}

cgi_end() {
cat << EOF
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

show_perc() {
	if [ $# -ge 1 -a "$1" -gt 3 ]; then
		echo "$1%"
	fi
}

stat_bar() {
    	local barstyle="br"
	if [ $# -gt 1 ]; then
		barstyle=$1; shift
	fi

	outhtml="<table class='bar $barstyle'><tr>"

	local i=1
	local sum=0
	for percent; do
	    	stat_bar_add_part $i $percent
		let i++
	done
	if let "sum < 100"; then
	    	stat_bar_add_part 0 $((100 - sum))
	fi
	if let "sum > 100"; then
		echo 'ERROR stat_bar: SUM > 100%'
	else
		echo "$outhtml</tr></table>"
	fi
}
stat_bar_add_part() {
    	local n=$1 percent=$2
	if let "percent > 0"; then
	    outhtml="$outhtml<td class='part$n' style='width: ${percent}%;'>$(show_perc $percent)</td>"
	fi
	let sum+=percent
}

# get a single query parameter (unescaped)
cgi_param() {
	local key=$1
	case "&$QUERY_STRING" in
		*"&$key="*)
			local value=${QUERY_STRING##*$key=}
			value=${value%%&*}
			httpd -d "$value"
			;;
	esac

}

back_button() {
    	local where=$1 title=${2:-$(lang de:"Zur&uuml;ck" en:"Back")}
	echo "<form action='$where'><input type='submit' value='$title'></form>"
}
