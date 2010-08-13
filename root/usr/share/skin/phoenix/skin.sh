skin_head() {
	local title=$1 id=$2
	cat << EOF
<title>$title&nbsp;&ndash; Freetz</title>
<link rel="stylesheet" type="text/css" href="/style/phoenix/base.css">
<link rel="stylesheet" type="text/css" href="/style/colorscheme.css">
EOF
	_cgi_print_extra_styles
}

skin_body_begin() {
	local title=$1 id=$2
	cat << EOF
<div id="world">
<div id="header">
<h1><a href="/cgi-bin/index.cgi" class="logo">Freetz</a>&nbsp;<a id="about" href="/cgi-bin/about.cgi" target="_blank">&ndash;</a> <span class="title">$title</span></h1>
</div>
<div id="container">
EOF

	_cgi_print_menu "$id"
	if [ "$MOD_DEV_NEW_MENU" != no ]; then
		_cgi_print_submenu "$id"
	fi

	echo "<div id='content'>"
}

skin_body_end() {
	cat << EOF
</div>
</div>
<div id="footer">
<span class="datetime" title="$(lang de:"Systemzeit des Routers" en:"Router's system time")">$(date +'$(lang de:"%d.%m.%Y" en:"%m/%d/%Y") %H:%M')</span>&nbsp;&ndash;
<span class="uptime" title="Uptime">$(uptime | sed -r 's/.*(up.*), load.*/\1/')</span>
<span class="version">$(html < /etc/.freetz-version)</span>
</div>
</div>
EOF
}

skin_sec_begin() {
	echo "<h1>$1</h1>"
}

skin_sec_end() {
	:
}

if [ "$WEBIF" = mww -a "$MOD_DEV_NEW_MENU" = no ]; then
	_cgi_print_menu() {
		local id=$1 sub= act_sub=
		case $id in
			pkg:mod|file:*) act_sub=settings ;;
			status*) act_sub=status ;;
			system|avmwif_*|rudi_*|firmware_*|backup_*) act_sub=system ;;
			packages|pkg:*) act_sub=packages ;;
		esac
		: ${sub:=$act_sub}

		_cgi_cached "menu_$sub" _cgi_menu "$sub" | _cgi_mark_active "$act_sub|$id"
	}
fi
