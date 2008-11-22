[ "$FREETZ_PATCH_DSL_EXPERT" == "y" ] || return 0
echo1 "adding dsl expert pages"
for file in \
        ${FILESYSTEM_MOD_DIR}/usr/www/avm/html/de/internet/adsl.html \
        ${FILESYSTEM_MOD_DIR}/usr/www/avm/html/de/internet/bits.html \
        ${FILESYSTEM_MOD_DIR}/usr/www/avm/html/de/internet/atm.html \
        ${FILESYSTEM_MOD_DIR}/usr/www/avm/html/de/internet/overview.html \
; do
  if [ -f "$file" ]; then
    sed -i -e "
    s|query box:settings.expertmode.activated ?>. .1.|query box:settings/expertmode/activated ?>' '0'|
    " "$file"
    sed -i -e "
/query box:settings.expertmode.activated ?>. .0./i \
<? if eq '<? query box:settings\/expertmode\/activated ?>' '1' \`\n\
<li><a href=\"javascript:uiDoLaborDSLPage()\">Einstellungen<\/a><\/li>\n\
\` ?>\
" "$file"
  echo "patching $file"
  fi
 done
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/dsl-expert-pages.patch"

