[ "$FREETZ_PATCH_DSL_EXPERT" == "y" ] || return 0
echo1 "adding dsl expert pages"

for file in \
  ${HTML_SPEC_MOD_DIR}/internet/adsl.html \
  ${HTML_SPEC_MOD_DIR}/internet/bits.html \
  ${HTML_SPEC_MOD_DIR}/internet/atm.html \
  ${HTML_SPEC_MOD_DIR}/internet/overview.html \
  ${HTML_SPEC_MOD_DIR}/internet/feedback.html \
  ; do
	[ ! -f "$file" ] && continue
	echo2 "patching $file"
	modsed "
	s|query box:settings.expertmode.activated ?>. .1.|query box:settings/expertmode/activated ?>' '0'|
	" "$file"
	modsed "
/query box:settings.expertmode.activated ?>. .0./i \
<? if eq '<? query box:settings\/expertmode\/activated ?>' '1' \`\n\
<li><a href=\"javascript:uiDoLaborDSLPage()\">Einstellungen<\/a><\/li>\n\
\` ?>\
" "$file"
done

modpatch \
  "$FILESYSTEM_MOD_DIR" \
  "${PATCHES_COND_DIR}/240-add_dsl-expert/" \
  "/usr/www/all/html/de/internet/awatch.js"

