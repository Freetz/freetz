echo1 "applying webmenu patch"
modsed \
  "/^\` ?>/{N;N;N;s/^\` ?>\n\(<.div>\n<.td>\n<td id=.Dataspalte.>\)/\` ?>\n<? include ..\/html\/menu2_freetz.html ?>\n\1/g}" \
  "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/menus/menu2.html"

#this creates menu2_freetz.html
cat > "${FILESYSTEM_MOD_DIR}/usr/www/all/html/menu2_freetz.html" <<EOF

<div style="position:relative;top:-21px">

<div class="small_bar_left_head"></div>
<div class="small_bar_right_head"></div>

<div class="small_bar_back_head">
<div id="MainWizardhead" style="padding-top:2px;">
<ul>
<li><a href="/cgi-bin/freetz_status" target="_blank">Freetz</a></li>
<li class="explain">Freetz Webinterface</li>
</ul>
</div>
</div>

<div class="small_bar_left_bottom"></div>
<div class="small_bar_right_bottom"></div>

<div class="small_bar_back_bottom">
<div id="MainWizardbottom">
</div>
</div>

</div>

<div class="clear_float"></div>

EOF
