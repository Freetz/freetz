_cgi_mark_active() {
	sed -r "s# id=(['\"])($1)\1# class='active'&#"
}

_cgi_print_menu() {
	local id=$1 sub
	case $id in
	    	settings) sub=mod ;;
		status*|daemons) sub=status ;;
		system|avmwif_*|rudi_*|firmware_*|backup_*) sub=system ;;
		*:*) sub=${id#*:}; sub=${sub%%:*} ;;
	esac

	new_menu "$sub" | _cgi_mark_active "$id"
}

MENU_CACHE=/mod/var/cache/menu

new_menu() {
	local sub=$1
	if ! [ -d "$MENU_CACHE" ]; then
	    source /usr/lib/libmodcgi.sh
	    new_menu_prepare "$MENU_CACHE"
	fi
	new_menu_deliver "$MENU_CACHE" "$sub"
}

new_menu_deliver() {
	local dir=$1 sub=$2
	local p="$dir/pkg"

	# assemble new menu

	echo "<ul class='menu'>"

	new_menu_tree "$dir/status"
	new_menu_tree "$dir/system"

	new_menu_package_tree mod
	while read -r pkg; do
		[ "$pkg" = mod ] && continue
		new_menu_package_tree "$pkg"
	done < "$dir/packages"

	echo "</ul>"
}

new_menu_tree() {
	local path=$1
	local base=${path##*/}
	echo -n "<li>"
	cat "$path"
	if [ "$base" = "$sub" -a -s "$path.sub" ]; then
		echo "<ul>"
		cat "$path.sub"
		echo "</ul>"
	fi
	echo "</li>"
}

new_menu_package_tree() {
	local pkg=$1
	new_menu_tree "$p/$pkg"
}

new_menu_prepare() {
	local dir=$1
	local p="$dir/pkg"
	mkdir -p "$p"

	# collect data for packages

	if [ -r /mod/etc/reg/cgi.reg ]; then
		local pkg title
		while IFS='|' read -r pkg title; do
			echo "has_conf=yes" >> "$p/$pkg.meta"
			echo "title=$(shell_escape "$title")" >> "$p/$pkg.meta"
			touch "$p/$pkg.sub"
		done < /mod/etc/reg/cgi.reg
	fi

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
		done
	fi

	if [ -r /mod/etc/reg/extra.reg ]; then
		while IFS='|' read -r pkg title sec cgi; do
			[ -z "$title" ] && continue
			echo "<li><a id='$(_cgi_id "extra:$pkg/$cgi")' class='extra' href='$(href extra "$pkg" "$cgi")'>$(html "$title")</a></li>" >> "$p/$pkg.sub"
		done < /mod/etc/reg/extra.reg
	fi

	# hard-coded packages
	echo "title=Freetz" >> "$p/mod.meta"
	echo "has_conf=yes" >> "$p/mod.meta"
	echo "title=SSH" >> "$p/authorized-keys.meta"

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

	for i in "$p"/*.sub; do
		pkg=${i##*/}; pkg=${pkg%.sub}
		title=$pkg
		if [ -r "$p/$pkg.meta" ]; then
			source "$p/$pkg.meta"
		fi
		echo "$title|$pkg"
	done | sort | cut -d"|" -f2 > "$dir/packages"

	echo "<a id='status' href='$(href mod status)'>Status</a>" > "$dir/status"
	echo "<a id='system' href='$(href mod system)'>System</a>" > "$dir/system"

	while read -r pkg; do
		new_menu_prepare_package "$pkg" > "$p/$pkg"
	done < "$dir/packages"
	
	rm -f "$p"/*.meta
}

new_menu_prepare_package() {
	local pkg=$1
	title=$pkg
	has_conf=no
	if [ -r "$p/$pkg.meta" ]; then
		source "$p/$pkg.meta"
	fi
	if [ "$has_conf" = yes ]; then
		echo -n "<a id='$(_cgi_id "pkg:$pkg")' class='conf' href='$(href cgi "$pkg")'>$(html "$title")</a>"
	else
		echo -n "<a href='/TODO'>$(html "$title")</a>"
	fi
}

shell_escape() {
	echo -n "'${1//'/'\''}'"
}
