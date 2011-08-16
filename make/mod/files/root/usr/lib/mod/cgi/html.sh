# HTML-escape pieces of texts, large ones in a streaming manner
# (large_text | html; html "$small_value")
html() {
	if [ $# -eq 0 ]; then
		sed -e '
			s/&/\&amp;/g
			s/</\&lt;/g
			s/>/\&gt;/g
			s/'\''/\&#39;/g
			s/"/\&quot;/g
		'
	else
		case $* in
			*[\&\<\>\'\"]*) httpd -e "$*" ;; #'
			*) printf "%s" "$*" ;;
		esac
	fi
}
