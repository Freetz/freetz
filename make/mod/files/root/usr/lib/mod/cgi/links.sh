#
# Generate Freetz-internal links to registered components; returns an
# absolute-path reference, which has already been HTML-escaped
#
# href file <pkg> <id>
# href extra <pkg> <cgi-name>
# href status <pkg> [<cgi-name>]
# href cgi <pkg> [<key-value>]...
#
# href mod [<name>] # link to special Freetz pages
#
href() {
	_cgi_location _href "$@"
}
_href() {
	local path=$1; shift
	local arg query=
	for arg; do
		query="${query:+${query}&amp;}${arg}"
	done
	echo "${path}${query:+?$query}"
}

back_button() {
	local title="$(lang de:"Zur&uuml;ck" en:"Back")"
	case $1 in
		--title=*) title=${1#--title=}; shift ;;
	esac
	_cgi_location _back_button "$@"
}
_back_button() {
	local path=$1 arg key value; shift
	echo -n "<form action='$path'>"
	for arg; do
		key=${arg%%=*}
		value=${arg#*=}
		echo "<input type='hidden' name='$key' value='$value'>"
	done
	echo "<div class='btn'><input type='submit' value='$title'></div></form>"
}

_cgi_location() {
	local out=$1; shift
	local type=$1
	case $type in
		file)   "$out" "/cgi-bin/file/${2}/${3}" ;;
		extra)  "$out" "/cgi-bin/extra/${2}/${3}" ;;
		status) "$out" "/cgi-bin/status/${2}/${3:-status}" ;;
		conf)
			if [ "$3" = _index ]; then
				"$out" "/cgi-bin/conf/${2}"
			else
				"$out" "/cgi-bin/conf/${2}/${3}"
			fi
			;;
		cgi)    local pkg=$2; shift 2
			"$out" "/cgi-bin/conf/$pkg" "$@" ;;
		mod)    case $2 in
				""|status) "$out" "/cgi-bin/status.cgi" ;;
				about)     "$out" "/cgi-bin/about.cgi" ;;
				daemons)   "$out" "/cgi-bin/service" ;;
				system)    "$out" "/cgi-bin/system.cgi" ;;
				backup)    "$out" "/cgi-bin/backup/index.cgi" ;;
				update)    "$out" "/cgi-bin/update/firmware.cgi" ;;
				support)   "$out" "/cgi-bin/support/index.cgi" ;;
				freetz)    "$out" "/cgi-bin/freetz.cgi" ;;
				extras)    "$out" "/cgi-bin/extra.cgi" ;;
				conf)      _cgi_location "$out" cgi mod ;;
			esac
			;;
		*)    "$out" "/error/unknown-type" "$type" ;;
	esac
}
