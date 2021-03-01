[ "$FREETZ_REMOVE_ASSISTANT" == "y" -o "FREETZ_REMOVE_UMTSD" == "y"  -o "$FREETZ_REMOVE_TR069" == "y" ] || return 0
echo1 "fixing login page"

if [ "$FREETZ_REMOVE_TR069" == "y" -o "$FREETZ_REMOVE_ASSISTANT" == "y" ]; then
	[ -e "${HTML_LANG_MOD_DIR}/html/logincheck.html" ] && modsed \
	  's/\(^var doTr069 = \).*/\1false;/g' \
	  "${HTML_LANG_MOD_DIR}/html/logincheck.html"
	modsed \
	  's!http.redirect("/tr69_autoconfig/.*!go_home()!g' \
	  "${LUA_MOD_DIR}/first.lua"

	modsed -r \
	  '/^[ \t]*box[.]get[.]wiztype[ \t]*=/ {
	    N
	    /\n[ \t]*return "tr069[^"]*"/ {
		s,^([ \t]*)([^\n]*)\n([ \t]*)([^\n]*)$,\1--\2\n\3--\4\n\3return first.go_home(),
	    }
	  }' \
	  "${LUA_MOD_DIR}/first.lua"
fi

if [ "$FREETZ_REMOVE_UMTSD" == "y" -o "$FREETZ_REMOVE_ASSISTANT" == "y" ]; then
	[ -e "${HTML_LANG_MOD_DIR}/html/logincheck.html" ] && modsed \
	  's/\(^var umts = \).*/\10;/g' \
	  "${HTML_LANG_MOD_DIR}/html/logincheck.html"
	modsed \
	  's/\(^local start_umts.*\) =.*/\1 = false/g' \
	  "${LUA_MOD_DIR}/first.lua"
fi

