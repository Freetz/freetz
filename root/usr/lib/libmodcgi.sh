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

#
# Easy setting of *_chk and *_sel variables for <input> elements
# depending on configuration variables.
#
#	swap_auto_chk=''
#	swap_man_chk=''
#	if [ "$MOD_SWAP" = "yes" ]; then 
#		swap_auto_chk=' checked'
#	else 
#		swap_man_chk=' checked'
#	fi
# 
# is equivalent to
#
#	check "$MOD_SWAP" yes:swap_auto "*":swap_man
#
_check() {
    local input=$1 alt key val var found=false; shift
    for alt; do
        key=${alt%%:*}; val=${alt#*:}
	var=${val:-$key}${suffix}
        if ! $found; then
            case $input in
                $key) eval "$var=\$checked"; found=true; continue ;;
            esac
        fi
        eval "$var="
    done
}
check()  suffix=_chk checked=" checked" _check "$@"
select() suffix=_sel checked=" selected" _check "$@"

_cgi_id() {
	case $1 in
		*[/]*) echo "$1" | sed "s#/#__#g" ;;
		*) echo "$1" ;;
	esac
}

#
# Generate Freetz-internal links to registered components; returns an
# absolute-path reference, which has already been HTML-escaped
#
# href file <pkg> <id>
# href extra <pkg> <cgi-name>
# href status <pkg> [<cgi-name>]
# href cgi <pkg>
#
href() {
    	local type=$1
	case $type in
	    file)	echo "/cgi-bin/file.cgi?id=${2}__${3}" ;;
	    extra)	echo "/cgi-bin/extras.cgi/${2}/${3}" ;;
	    status)	echo "/cgi-bin/pkgstatus.cgi?cgi=${2}/${3:-status}" ;;
	    cgi)	echo "/cgi-bin/pkgconf.cgi?pkg=$2" ;;
	    *)		echo "/error/unknown-type?$type" ;;
	esac
}

_cgi_mark_active() {
    	sed -r "s# id=(['\"])$1\1# class='active'&#"
}

_cgi_print_menu() {
	local id=$1 sub
	case $id in
		settings|file_*) sub=settings ;;
		status*) sub=status ;;
	    	system|rudi_*|firmware_*|backup_*) sub=system ;;
		*) sub=packages ;;
	esac

	local cache="/mod/var/cache/menu_$sub"
	#
	# First, try to output cache. This does not depend on an existence 
	# check to avoid race conditions (the file might have been deleted
	# in the meantime).
	#	
	if ! cat "$cache" 2> /dev/null; then 
		#
		# Regenerate cache in a private file. Hence, incomplete
		# states of the cache are invisible to others (though they 
		# might be generating their own versions concurrently)
		#
		_cgi_menu "$sub" | tee "$cache.$$"
		#
		# Atomically replace global cache, making our changes visible
		# (last writer wins)
		#
		mv "$cache.$$" "$cache"
	fi | _cgi_mark_active "$id"
}

_cgi_menu() {
local sub=$1
cat << EOF
<ul class="menu">
<li><a id="status" href="/cgi-bin/status.cgi">Status</a>
EOF

if [ "$sub" = status -a -r /mod/etc/reg/status.reg ]; then
    	local pkg title cgi
	echo "<ul>"
	while IFS='|' read -r pkg title cgi; do
		echo "<li><a id='$(_cgi_id "status_$pkg/$cgi")' href='$(href status "$pkg" "$cgi")'>$(html "$title")</a></li>"
	done < /mod/etc/reg/status.reg 
	echo "</ul>"
fi

cat << EOF
</li>
<li><a id="daemons" href="/cgi-bin/daemons.cgi">$(lang de:"Dienste" en:"Services")</a></li>
<li><a id="settings" href="/cgi-bin/settings.cgi">$(lang de:"Einstellungen" en:"Settings")</a>
EOF

if [ "$sub" = settings -a -r /mod/etc/reg/file.reg ]; then
    	local id title sec def _
	echo "<ul>"
	# sort by title
	while IFS='|' read -r id _; do
		echo "$_|$id"
	done  < /mod/etc/reg/file.reg | sort |
	while IFS='|' read -r title sec def id; do
		echo "<li><a id='$(_cgi_id "file_$id")' href='/cgi-bin/file.cgi?id=$id'>$(html "$title")</a></li>"
	done
	echo "</ul>"
fi

cat << EOF
</li>
<li><a id="packages" href="/cgi-bin/packages.cgi">$(lang de:"Pakete" en:"Packages")</a>
EOF

if [ "$sub" = packages -a -r /mod/etc/reg/cgi.reg ]; then
    	local pkg title
	echo "<ul>"
	while IFS='|' read -r pkg title; do
		echo "<li><a id='$(_cgi_id "pkg_$pkg")' href='$(href cgi "$pkg")'>$(html "$title")</a></li>"
	done < /mod/etc/reg/cgi.reg 
	echo "</ul>"
fi

cat << EOF
</li>
<li><a id="extras" href="/cgi-bin/extras.cgi">Extras</a></li>
<li><a id="system" href="/cgi-bin/system.cgi">System</a>
EOF

if [ "$sub" = system ]; then
	cat <<- EOF
	<ul>
	<li><a id="backup_restore" href="/cgi-bin/backup_restore.cgi">$(lang de:"Sichern &amp; Wiederherstellen" en:"Backup &amp; restore")</a></li>
	<li><a id="firmware_update" href="/cgi-bin/firmware_update.cgi">$(lang de:"Firmware-Update" en:"Firmware update")</a></li>
	<li><a id="rudi_shell" href="/cgi-bin/rudi_shell.cgi" target="_blank">$(lang de:"Rudi-Shell" en:"Rudi shell")</a></li>
	</ul>
	EOF
fi

cat << EOF
</li>
</ul>
EOF
}

cgi_begin() {
local title=$(html "$1") id=${2:+$(_cgi_id "$2")}
local CR=$'\r'
cat << EOF
Content-Type: text/html; charset=ISO-8859-1${CR}
Content-Language: $(lang de:"de" en:"en")${CR}
Expires: 0${CR}
Pragma: no-cache${CR}
${CR}
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
EOF
_cgi_head "$title" "$id"
cat << EOF
</head>
<body>
EOF
_cgi_body_begin "$title" "$id"
}

cgi_end() {
_cgi_body_end
cat << EOF
</body>
</html>
EOF
}

# 
# Simplistic versions of the functions to be overridden by skins
#
_cgi_head() {
    	local title=$1 id=$2
	echo "<title>$title</title>"
}
_cgi_body_begin() {
    	local title=$1 id=$2
	echo "<h1>$title</h1>"
	_cgi_print_menu "$id"
}
_cgi_body_end() {
    	:
}
sec_begin() {
    	echo "<div class='sec'><h2>$1</h2>"
}
sec_end() {
    	echo "</div>"
}

#
# Load the desired skin (very rough cookie parsing at the moment)
#
case $HTTP_COOKIE in
    *skin=*) skin=${HTTP_COOKIE##*skin=}; skin=${skin%%[^A-Za-z0-9_]*} ;;
    *) skin=legacy ;;
esac
[ -r "/usr/share/skin/$skin/skin.sh" ] || skin=legacy
. "/usr/share/skin/$skin/skin.sh"

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
	echo "<form action='$where'><div class='btn'><input type='submit' value='$title'></div></form>"
}
