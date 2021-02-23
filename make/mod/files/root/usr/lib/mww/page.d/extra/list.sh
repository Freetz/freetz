EXTRA_REG=/mod/etc/reg/extra.reg
[ -e "$EXTRA_REG" ] || touch "$EXTRA_REG"

PKG_REG=/mod/etc/reg/pkg.reg

_cgi_extras() {
	if [ ! -s "$EXTRA_REG" ]; then
		echo "<p><i>$(lang de:"keine Extras" en:"no extras")</i></p>"
		return
	fi
	[ -e "$PKG_REG" ] || touch "$PKG_REG"

	unset cur_pkg
	while IFS='|' read -r pkg title sec cgi; do
		[ -z "$title" ] && continue
		if [ "$cur_pkg" != "$pkg" ]; then
			if [ "$pkg" = "mod" ]; then
				heading="$(lang de:"Mod-Extras" en:"Mod extras")"
			else
				IFS='|'; set -- $(grep "^$pkg|" "$PKG_REG")
				heading=${2:-$pkg}
			fi

			[ -n "$cur_pkg" ] && echo '</ul>'
			echo "<h1>$(html "$heading")</h1>"
			echo '<ul>'
			cur_pkg=$pkg
		fi
		echo "<li><a href='$(href extra "$pkg" "$cgi")'>$(html "$title")</a></li>"
	done < "$EXTRA_REG"
	echo '</ul>'
}

cgi --id=extras
cgi_begin 'Extras'

_cgi_cached extras _cgi_extras

cgi_end
