_cgi_help_url() {
	local path=$1
#	echo "https://freetz-ng.github.io/freetz-ng/wiki${path}"
	echo -n "https://github.com/Freetz-NG/freetz-ng/blob/master/make/README.md#"
	echo $path | sed 's,.*/,,;s,#.*,,'
}
