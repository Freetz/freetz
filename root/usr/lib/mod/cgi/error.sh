# print (HTML) error message consistently
print_error() {
	echo "<p class='error'><b>$(lang de:"Fehler" en:"Error")</b>: $1</p>"
}

# complete error page
cgi_error() {
	local message=$1
	cgi_begin '$(lang de:"Fehler" en:"Error")'
	print_error "$message"
	cgi_end
}
