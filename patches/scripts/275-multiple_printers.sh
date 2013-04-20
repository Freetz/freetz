[ "$FREETZ_PATCH_MULTIPLE_PRINTERS" == "y" ] || return 0
echo1 "adding support for multiple printers"

modsed \
  's/\(str += name\);/\1.replace(\/^\\s+|\\s+$\/g, "").replace(\/\\t\/g, "<br \/>");/g' \
  "${HTML_SPEC_MOD_DIR}/usb/status.js"

modsed \
  's/\(\.tAura {width: .*; table-layout: \)fixed\(.*$\)/\1auto\2/g' \
  "${HTML_SPEC_MOD_DIR}/usb/status.js"

modpatch \
  "$FILESYSTEM_MOD_DIR" \
  "${PATCHES_COND_DIR}/275-multiple_printers/"

