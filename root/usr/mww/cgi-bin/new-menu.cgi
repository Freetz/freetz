#!/bin/sh
# Prototype of new menu structure (no optimization/caching)

source /usr/lib/libmodcgi.sh

new_menu() {
local sub=$1

TMP=/tmp/new-menu
rm -rf "$TMP"
mkdir -p "$TMP"

# collect data for packages

if [ -r /mod/etc/reg/cgi.reg ]; then
    local pkg title
    while IFS='|' read -r pkg title; do
	echo "has_conf=yes" >> "$TMP/$pkg.meta"
	echo "title='${title//'/'\''}'" >> "$TMP/$pkg.meta"
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
	echo "<li><a class='file' href='$(href file "$pkg" "$id")'>$(html "$title")</a></li>" >> "$TMP/$pkg.items"
    done
fi

if [ -r /mod/etc/reg/extra.reg ]; then
    while IFS='|' read -r pkg title sec cgi; do
	[ -z "$title" ] && continue
	echo "<li><a class='extra' href='$(href extra "$pkg" "$cgi")'>$(html "$title")</a></li>" >> "$TMP/$pkg.items"
    done < /mod/etc/reg/extra.reg
fi

if false; then
if [ -r /mod/etc/reg/status.reg ]; then
    local pkg title cgi
    while IFS='|' read -r pkg title cgi; do
	echo "<li><a class='status' href='$(href status "$pkg" "$cgi")'>$(html "$title")</a></li>" >> "$TMP/$pkg.items"
    done < /mod/etc/reg/status.reg
fi
fi

# hard-coded packages
echo "title=Freetz" >> "$TMP/mod.meta"
echo "has_conf=yes" >> "$TMP/mod.meta"
echo "title=SSH" >> "$TMP/authorized-keys.meta"

# assemble new menu

echo "<h2>new</h2>"
echo "<ul>"
cat << EOF
<li><a id="status" href="$(href mod status)">Status</a>
EOF

sub=status
if [ "$sub" = status -a -r /mod/etc/reg/status.reg ]; then
	local pkg title cgi
	echo "<ul>"
	cat << EOF
<li><a id="daemons" href="$(href mod daemons)">$(lang de:"Dienste" en:"Services")</a></li>
EOF
	while IFS='|' read -r pkg title cgi; do
		echo "<li><a href='$(href status "$pkg" "$cgi")'>$(html "$title")</a></li>"
	done < /mod/etc/reg/status.reg
	echo "</ul>"
fi

cat << EOF
<li><a id="system" href="$(href mod system)">System</a>
EOF

sub=system
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

echo "</ul><hr><ul>"

package_tree() {
    local pkg=$1
    title=$pkg
    has_conf=no
    if [ -r "$TMP/$pkg.meta" ]; then
	source "$TMP/$pkg.meta"
    fi
    if [ "$has_conf" = yes ]; then
	echo "<li><a class='conf' href='$(href cgi "$pkg")'>$(html "$title")</a><ul>"
    else
	echo "<li>$(html "$title")<ul>"
    fi
    cat "$TMP/$pkg.items"
    echo "</ul></li>"
}

for i in "$TMP"/*.items; do
    pkg=${i##*/}; pkg=${pkg%.items}
    title=$pkg
    if [ -r "$TMP/$pkg.meta" ]; then
	source "$TMP/$pkg.meta"
    fi
    echo "$title|$pkg" >> "$TMP/_packages"
done

package_tree mod
sort "$TMP/_packages" | while IFS="|" read -r title pkg; do
    [ "$pkg" = mod ] && continue
    package_tree "$pkg"
done

echo "</ul>"
}

old_menu() {
echo "<h2>old</h2>"

cat << EOF
<ul>
<li><a id="status" href="$(href mod status)">Status</a>
EOF

sub=status
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
<li><a id="settings" href="$(href mod conf)">$(lang de:"Einstellungen" en:"Settings")</a>
EOF

sub=settings
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

sub=packages
if [ "$sub" = packages -a -r /mod/etc/reg/cgi.reg ]; then
	local pkg title
	echo "<ul>"
	while IFS='|' read -r pkg title; do
		echo "<li><a id='$(_cgi_id "pkg:$pkg")' href='$(href cgi "$pkg")'>$(html "$title")</a></li>"
	done < /mod/etc/reg/cgi.reg
	echo "</ul>"
fi

cat << EOF
</li>
<li><a id="extras" href="$(href mod extras)">Extras</a></li>
<li><a id="system" href="$(href mod system)">System</a>
EOF

sub=system
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

cgi_begin "New menu structure"
echo "<table><tr style='vertical-align: top'><td>"
new_menu
echo "</td><td>"
old_menu
echo "</td></tr></table>"
cgi_end
