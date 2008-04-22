frm_begin() {
html_cat << EOF
<form action="/cgi-bin/save.cgi?form=pkg_$1" method="post">
EOF
}

frm_end() {
html_cat << EOF
<div class="btn"><input type="submit" value="$(lang de:"&Uuml;bernehmen" en:"Apply")"></div>
</form>
<form class="btn" action="/cgi-bin/save.cgi?form=def_$1" method="post">
<div class="btn"><input type="submit" value="$(lang de:"Standard" en:"Defaults")"></div>
</form>
EOF
}
