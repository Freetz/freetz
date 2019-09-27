[ "$FREETZ_TAGGING_STRING" != "none" ] || return 0
[ "$FREETZ_AVM_VERSION_07_1X_MIN" == "y" ] || return 0

echo1 "fixing tagged logo"

for file in login.css main.css singleside_old.css; do
	[ ! -e "$HTML_LANG_MOD_DIR/css/rd/$file" ] && continue
	modsed -r \
	  's/(;*background-size:) *7rem[^;]*;/\1 6rem;/g' \
	  "$HTML_LANG_MOD_DIR/css/rd/$file"
done

