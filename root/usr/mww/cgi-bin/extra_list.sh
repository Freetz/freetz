CGI_REG=/mod/etc/reg/cgi.reg

_cgi_extras() {
	if [ ! -s "$EXTRA_REG" ]; then
		echo '<p><i>$(lang de:"keine Extras" en:"no extras")</i></p>'
		return
	fi
	[ -e "$CGI_REG" ] || touch "$CGI_REG"

	unset cur_pkg
	cat "$EXTRA_REG" | while IFS='|' read -r pkg title sec cgi; do
		[ -z "$title" ] && continue
		if [ "$cur_pkg" != "$pkg" ]; then
			if [ "$pkg" = "mod" ]; then
				heading='$(lang de:"Mod-Extras" en:"Mod extras")'
			else
				IFS='|'; set -- $(grep "^$pkg|" "$CGI_REG")
				heading=${2:-$pkg}
			fi

			[ -n "$cur_pkg" ] && echo '</ul>'
			echo "<h1>$heading</h1>"
			echo '<ul>'
			cur_pkg=$pkg
		fi
		echo "<li><a href='$(href extra "$pkg" "$cgi")'>$title</a></li>"
	done
	echo '</ul>'
}

cgi_begin 'Extras' 'extras'

_cgi_cached extras _cgi_extras

cgi_end
