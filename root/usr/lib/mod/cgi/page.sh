# A list of extra CSS stylesheets
_CGI_STYLES=
_cgi_print_extra_styles() {
	local style
	for style in $_CGI_STYLES; do
		echo "<link rel='stylesheet' type='text/css' href='$(html "$style")'>"
	done
}

#
# Set options for the following CGI page
#
_cgi_option() {
	local opt=$1 value=$2 uri
	case $opt in
		style) 
			case $value in
				/*|*:*) uri=$value ;;
				*) uri="/style/$value" ;;
			esac
			export _CGI_STYLES="$_CGI_STYLES $uri"
			;;
		id)
			export _CGI_ID=$(_cgi_id "$value") ;;
		*)
			cgi_error "cgi: Unknown option '$opt'"
			exit 1
			;;
	esac
}

#
# User frontend
# cgi --opt1=value1 --opt2 value2
#
cgi() {
	local opt value
	while [ $# -gt 0 ]; do
		case $1 in
			--*=*)
				opt=${1#--}; opt=${opt%%=*}
				value=${1#--*=}
				shift
				_cgi_option "$opt" "$value"
				;;
			--*)
				opt=${1#--}
				value=$2
				shift 2
				_cgi_option "$opt" "$value"
				;;
			*)
				cgi_error "cgi: Illegal argument '$1'"
				exit 1
				;;
		esac
	done
}

cgi_begin() {
	# disable functions
	cgi() {
		cgi_error "cgi must be called before cgi_begin"; exit 1
	}
	local title=$1 id=${2:+$(_cgi_id "$2")}
	if [ -n "$_CGI_ID" ]; then
		id=$_CGI_ID
	fi
	local CR=$'\r'
	cat << EOF
Content-Type: text/html; charset=ISO-8859-1${CR}
Content-Language: $(lang de:"de" en:"en")${CR}
Expires: 0${CR}
Pragma: no-cache${CR}
${CR}
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
EOF
	_cgi_head "$title" "$id"
	cat << EOF
</head>
<body ${id:+id="$id"}>
EOF
	_cgi_body_begin "$title" "$id"
}

cgi_end() {
_cgi_body_end
cat << EOF
</body>
</html>
EOF
}

#
# Simplistic versions of the functions to be overridden by skins
#
_cgi_head() {
	local title=$1 id=$2
	echo "<title>$title</title>"
	_cgi_print_extra_styles
}
_cgi_body_begin() {
	local title=$1 id=$2
	echo "<h1>$title</h1>"
	_cgi_print_menu "$id"
}
_cgi_body_end() {
	:
}
sec_begin() {
	echo "<div class='sec'><h2>$1</h2>"
}
sec_end() {
	echo "</div>"
}
