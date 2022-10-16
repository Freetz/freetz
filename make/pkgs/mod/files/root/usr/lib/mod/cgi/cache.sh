_cgi_cached() {
	local cache="/mod/var/cache/$1"; shift
	#
	# First, try to output cache. This does not depend on an existence
	# check to avoid race conditions (the file might have been deleted
	# in the meantime).
	#
	if ! cat "$cache" 2> /dev/null; then
		#
		# Regenerate cache in a private file. Hence, incomplete
		# states of the cache are invisible to others (though they
		# might be generating their own versions concurrently)
		#
		"$@" | tee "$cache.$$"
		#
		# Atomically replace global cache, making our changes visible
		# (last writer wins)
		#
		mv "$cache.$$" "$cache"
	fi
}
