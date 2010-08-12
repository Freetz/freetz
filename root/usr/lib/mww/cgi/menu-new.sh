_cgi_mark_active() {
	local sub=$1 id=$2
	sed -r "
		s# id=(['\"])($id)\1# class='active'&#
		s#(<li)(>.* id=(['\"])($sub)\3)#\1 class='open'\2#
		s# id=\"[^\"]*\"##
		s# id='[^']*'##
		s# class='([^']*)' class='([^']*)'# class='\1 \2'#
	"
}
_cgi_submenu() {
	local id=$1
	case $id in
		status*|daemons) sub=status ;;
		system|avmwif_*|rudi_*|firmware_*|backup_*) sub=system ;;
		*:*) sub=${id#*:}; sub="pkg:${sub%%:*}" ;;
	esac
	echo "$sub"
}

_cgi_print_menu() {
	local id=$1
	local sub=$(_cgi_submenu "$id")
	new_menu | _cgi_mark_active "$sub" "$id"
}
_cgi_print_submenu() {
	local id=$1
	local sub=$(_cgi_submenu "$id")
	new_submenu "$sub" | _cgi_mark_active "" "$id"
}

MENU_CACHE=/mod/var/cache/menu

new_menu_init() {
	if [ ! -d "$MENU_CACHE" -o -e "$MENU_CACHE.stale" ]; then
		rm -f "$MENU_CACHE.stale"
		new_menu_prepare "$MENU_CACHE"
	fi
}

new_menu() {
	local sub=$1
	new_menu_init
	new_menu_deliver "$MENU_CACHE" "$sub"
}

# display only the current submenu
new_submenu() {
	local sub=$1 dir=$MENU_CACHE
	[ -z "$sub" ] && return
	new_menu_init
	
	echo "<ul class='menu new sub'>"
	case $sub in
		pkg:*) cat "$dir/pkg/${sub#pkg:}.sub" ;;
		*) cat "$dir/$sub.sub" ;;
	esac
	echo "</ul>"
}

new_menu_deliver() {
	local dir=$1 sub=$2
	local p="$dir/pkg"

	# assemble new menu

	echo "<ul class='menu new'>"

	new_menu_tree "$dir/status"
	new_menu_tree "$dir/system"

	while read -r pkg; do
		new_menu_package_tree "$pkg"
	done < "$dir/packages"

	echo "</ul>"
}

new_menu_tree() {
	local path=$1
	local base=${path##*/}
	echo -n "<li>"
	cat "$path"
	if [ \( "$base" = "$sub" -o -z "$sub" \) -a -s "$path.sub" ]; then
		echo "<ul>"
		cat "$path.sub"
		echo "</ul>"
	fi
	echo "</li>"
}

new_menu_package_tree() {
	local pkg=$1 sub
	if [ "$sub" = "pkg:$pkg" ]; then
	    sub=$pkg
	else
	    sub=
	fi
	new_menu_tree "$p/$pkg"
}

new_menu_prepare() {
	local dir=$1
	local p="$dir/pkg"
	rm -rf "$dir"
	mkdir -p "$p"

	# collect data for packages

	if [ -r /mod/etc/reg/cgi.reg ]; then
		local pkg title
		while IFS='|' read -r pkg title; do
			echo "has_conf=yes" >> "$p/$pkg.meta"
			echo "title=$(shell_escape "$title")" >> "$p/$pkg.meta"
			if [ ! -e "$p/$pkg.index" ]; then
			    echo "$(href cgi "$pkg")" > "$p/$pkg.index"
			fi
			echo "<li><a id='$(_cgi_id "conf:$pkg")' class='conf' href='$(href cgi "$pkg")'>$(lang de:"Einstellungen" en:"Settings")</a></li>" > "$p/$pkg.sub"
		done < /mod/etc/reg/cgi.reg
	fi
	echo "<li><a id='$(_cgi_id "conf:mod")' class='conf' href='$(href mod conf)'>$(lang de:"Einstellungen" en:"Settings")</a></li>" > "$p/mod.sub"
	echo "$(href mod conf)" > "$p/mod.index"

	if [ -r /mod/etc/reg/file.reg ]; then
		local pkg id title sec def _
		# sort by title
		while IFS='|' read -r pkg id _; do
			echo "$_|$pkg|$id"
		done  < /mod/etc/reg/file.reg | sort |
		while IFS='|' read -r title sec def pkg id; do
			# FIXME: Temporary title change
			case $title in
				Freetz:*) title=${title#Freetz: } ;;
				SSH:*) title=${title#SSH: } ;;
			esac
			echo "<li><a id='$(_cgi_id "file:$pkg/$id")' class='file' href='$(href file "$pkg" "$id")'>$(html "$title")</a></li>" >> "$p/$pkg.sub"
			if [ ! -e "$p/$pkg.index" ]; then
			    echo "$(href file "$pkg" "$id")" > "$p/$pkg.index"
			fi
		done
	fi

	if [ -r /mod/etc/reg/extra.reg ]; then
		while IFS='|' read -r pkg title sec cgi; do
			[ -z "$title" ] && continue
			echo "<li><a id='$(_cgi_id "extra:$pkg/$cgi")' class='extra' href='$(href extra "$pkg" "$cgi")'>$(html "$title")</a></li>" >> "$p/$pkg.sub"
			if [ ! -e "$p/$pkg.index" ]; then
			    echo "$(href extra "$pkg" "$cgi")" > "$p/$pkg.index"
			fi
		done < /mod/etc/reg/extra.reg
	fi

	# hard-coded packages
	echo "title=Freetz" >> "$p/mod.meta"
	echo "has_conf=yes" >> "$p/mod.meta"
	if [ -e "$p/authorized-keys.sub" ]; then
		echo "title=SSH" >> "$p/authorized-keys.meta"
	fi

	# system menu
	{
		. /usr/lib/libmodredir.sh
		cat << EOF
<li><a id="backup_restore" href="/cgi-bin/backup/index.cgi">$(lang de:"Sichern &amp; Wiederherstellen" en:"Backup &amp; restore")</a></li>
<li><a id="firmware_update" href="$(href mod update)">$(lang de:"Firmware-Update" en:"Firmware update")</a></li>
<li><a id="rudi_shell" href="/cgi-bin/shell/index.cgi" target="_blank">$(lang de:"Rudi-Shell" en:"Rudi shell")</a></li>
<li><a id="avmwif_link" href="http://$(self_host)/" target="_blank">$(lang de:"AVM-Webinterface" en:"AVM web interface")</a></li>
EOF
	} > "$dir/system.sub"

	{
		if [ -r /mod/etc/reg/status.reg ]; then
			local pkg title cgi
			cat << EOF
<li><a id="daemons" href="$(href mod daemons)">$(lang de:"Dienste" en:"Services")</a></li>
EOF
			while IFS='|' read -r pkg title cgi; do
				echo "<li><a id='$(_cgi_id "status:$pkg/$cgi")' href='$(href status "$pkg" "$cgi")'>$(html "$title")</a></li>"
			done < /mod/etc/reg/status.reg
		fi
	} > "$dir/status.sub"

	echo "mod" > "$dir/packages"
	for i in "$p"/*.sub; do
		pkg=${i##*/}; pkg=${pkg%.sub}
		[ "$pkg" = mod ] && continue
		title=$pkg
		if [ -r "$p/$pkg.meta" ]; then
			source "$p/$pkg.meta"
		fi
		echo "$title|$pkg"
	done | sort | cut -d"|" -f2 >> "$dir/packages"

	echo "<a id='status' href='$(href mod status)'>Status</a>" > "$dir/status"
	echo "<a id='system' href='$(href mod system)'>System</a>" > "$dir/system"

	while read -r pkg; do
		new_menu_prepare_package "$pkg" > "$p/$pkg"
	done < "$dir/packages"
	
	rm -f "$p"/*.meta "$p"/*.index
}

new_menu_prepare_package() {
	local pkg=$1
	title=$pkg
	has_conf=no
	if [ -r "$p/$pkg.meta" ]; then
		source "$p/$pkg.meta"
	fi
	echo -n "<a id='$(_cgi_id "pkg:$pkg")' class='package' href='$(cat "$p/$pkg.index")'>$(html "$title")</a>"
}

shell_escape() {
	echo -n "'${1//'/'\''}'"
}
