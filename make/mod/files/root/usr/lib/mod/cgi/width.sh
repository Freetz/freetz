# The basic idea is to introduce _cgi_width, which is the minimum width a skin
# shall provide for a content cgi (besides the menu for legacy). A content cgi
# can rely on _cgi_width px being available at any time but it should not try
# to use more than _cgi_width pixels.

# This is the minimum width for the content cgi. It was chosen around
# 730-150-25px because of the former default settings (cgi-width was 730px, the
# default menu width was 150px, separated by about 25px). Some Freetz pages
# look crappy if there is less space.
_cgi_width_minimum=600

# Private helper function: Export the actual _cgi_width attribute after setting
# it to either a predefined minimum or to $1. Used by cgi_width_setup only.
set_valid_width() {
	local w=$1
	let "_cgi_width=(w > _cgi_width_minimum ? w : _cgi_width_minimum)"
	export _cgi_width
}

# This will set _cgi_width to either the width requested by the content cgi via
# "cgi --width=1234" or to the width the user specified in the WebIf settings.
# It disables cgi_width_at_least() because extra space may only be requested in
# advance. This function is called by cgi_begin.
cgi_width_setup() {
	cgi_width_at_least() {
		cgi_error "cgi_width_at_least must be called before cgi_begin"; exit 1
	}
	if [ -n "$_cgi_width_extra" ]; then
		set_valid_width "$_cgi_width_extra"
	else
		set_valid_width "$MOD_CGI_WIDTH"
	fi
}

# In general, a skin takes responsibility that the content cgi has at least
# _cgi_width px in width for its own use, but that is only within its main
# content container (div#world in phoenix). If the content cgi calls sec_begin
# or sec_end, it might be necessary (for legacy it is) to temporarily reduce
# the available width. Therefore, this function is to be called by a skin.sh
# file. (The only public interface for cgi pages is `cgi --width`!)
cgi_width_alter() {
	cgi_width_setup() {
		cgi_error "cgi_width_setup must be called before cgi_width_alter"; exit 1
	}
	cgi_width_at_least() {
		cgi_error "cgi_width_at_least must be called before cgi_begin"; exit 1
	}
	let _cgi_width+="$1"
}

# This function is called internally by "cgi --width=1234" and allows to
# setup a cgi page that is wider than usual (which is predefined minimum or
# user defined setting).
# It should rarely be used, i.e. only if the cgi (e.g. avm firewall cgi) really
# needs at minimum some X pixels to look okay. It does not overwrite the user
# setting if that setting is even larger.
cgi_width_at_least() {
	[ "$1" -gt "$MOD_CGI_WIDTH" ] && export _cgi_width_extra=$1
}
