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
		file)   "$out" "/cgi-bin/file.cgi/${2}/${3}" ;;
		extra)  "$out" "/cgi-bin/extra.cgi/${2}/${3}" ;;
		status) "$out" "/cgi-bin/pkgstatus.cgi/${2}/${3:-status}" ;;
		cgi)    local pkg=$2; shift 2
			"$out" "/cgi-bin/conf.cgi/$pkg" "$@" ;;
		mod)    case $2 in
				""|status) "$out" "/cgi-bin/status.cgi" ;;
				extras)    "$out" "/cgi-bin/extra.cgi" ;;
				daemons)   "$out" "/cgi-bin/service.cgi" ;;
				about)     "$out" "/cgi-bin/about.cgi" ;;
				packages)  "$out" "/cgi-bin/packages.cgi" ;;
				system)    "$out" "/cgi-bin/system.cgi" ;;
				conf)      _cgi_location "$out" cgi mod ;;
				update)    "$out" "/cgi-bin/update/firmware.cgi" ;;
			esac
			;;
		*)    "$out" "/error/unknown-type" "$type" ;;
	esac
}
