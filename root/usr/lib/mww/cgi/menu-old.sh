_cgi_mark_active() {
	sed -r "s# id=(['\"])($1)\1# class='active'&#"
}

_cgi_print_menu() {
	local id=$1 sub
	case $id in
		conf:mod|file:*) sub=settings ;;
		status*) sub=status ;;
		system|avmwif_*|rudi_*|firmware_*|backup_*) sub=system ;;
		*) sub=packages ;;
	esac

	_cgi_cached "menu_$sub" _cgi_menu "$sub" | _cgi_mark_active "$id"
}

_cgi_menu() {
local sub=$1
cat << EOF
<ul class="menu">
<li><a id="status" href="$(href mod status)">Status</a>
EOF

if [ "$sub" = status -a -r /mod/etc/reg/status.reg ]; then
	local pkg title cgi
	echo "<ul>"
	while IFS='|' read -r pkg title cgi; do
		echo "<li><a id='$(_cgi_id "status:$pkg/$cgi")' href='$(href status "$pkg" "$cgi")'>$(html "$title")</a></li>"
	done < /mod/etc/reg/status.reg
	echo "</ul>"
fi

cat << EOF
</li>
<li><a id="daemons" href="$(href mod daemons)">$(lang de:"Dienste" en:"Services")</a></li>
<li><a id="conf:mod" href="$(href mod conf)">$(lang de:"Einstellungen" en:"Settings")</a>
EOF

if [ "$sub" = settings -a -r /mod/etc/reg/file.reg ]; then
	local pkg id title sec def _
	echo "<ul>"
	# sort by title
	while IFS='|' read -r pkg id _; do
		echo "$_|$pkg|$id"
	done  < /mod/etc/reg/file.reg | sort |
	while IFS='|' read -r title sec def pkg id; do
		echo "<li><a id='$(_cgi_id "file:${pkg}/${id}")' href='$(href file "$pkg" "$id")'>$(html "$title")</a></li>"
	done
	echo "</ul>"
fi

cat << EOF
</li>
<li><a id="packages" href="$(href mod packages)">$(lang de:"Pakete" en:"Packages")</a>
EOF

if [ "$sub" = packages -a -r /mod/etc/reg/cgi.reg ]; then
	local pkg title
	echo "<ul>"
	while IFS='|' read -r pkg title; do
		echo "<li><a id='$(_cgi_id "conf:$pkg")' href='$(href cgi "$pkg")'>$(html "$title")</a></li>"
	done < /mod/etc/reg/cgi.reg
	echo "</ul>"
fi

cat << EOF
</li>
<li><a id="extras" href="$(href mod extras)">Extras</a></li>
<li><a id="system" href="$(href mod system)">System</a>
EOF

if [ "$sub" = system ]; then
	. /usr/lib/libmodredir.sh
	cat <<- EOF
	<ul>
	<li><a id="backup_restore" href="/cgi-bin/backup/index.cgi">$(lang de:"Sichern &amp; Wiederherstellen" en:"Backup &amp; restore")</a></li>
	<li><a id="firmware_update" href="$(href mod update)">$(lang de:"Firmware-Update" en:"Firmware update")</a></li>
	<li><a id="rudi_shell" href="/cgi-bin/shell/index.cgi" target="_blank">$(lang de:"Rudi-Shell" en:"Rudi shell")</a></li>
	<li><a id="avmwif_link" href="http://$(self_host)/" target="_blank">$(lang de:"AVM-Webinterface" en:"AVM web interface")</a></li>
	</ul>
	EOF
fi

cat << EOF
</li>
</ul>
EOF
}
