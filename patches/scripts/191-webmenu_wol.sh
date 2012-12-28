[ "$FREETZ_PACKAGE_WOL_CGI" == "y" ] || return 0
echo1 "applying wol patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/${FREETZ_TYPE_LANGUAGE}/webmenu-wol-${FREETZ_TYPE_PREFIX}.patch"

# menu2_freetz.html created by 190-webmenu
# append to this file
cat >> "${FILESYSTEM_MOD_DIR}/usr/www/all/html/menu2_freetz.html" <<EOF

<div style="position:relative;top:-21px">

<div class="small_bar_left_head"></div>
<div class="small_bar_right_head"></div>

<div class="small_bar_back_head">
<div id="MainWizardhead" style="padding-top:2px;">
<ul>
<li><a href="/cgi-bin/freetz_wol" target="_blank">Freetz WOL</a></li>
<li class="explain">Freetz WOL Webinterface</li>
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
