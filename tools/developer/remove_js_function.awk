# Remove a function from a JavaScript file.
#
# This script requires you to specify the name of the function to be removed
# as variable 'fname'. Examples:
#   cat testfile | awk -f remove_js_function.awk -v fname=foo
#   cat testfile |
#     awk -f remove_js_function.awk -v fname=bar |
#     awk -f remove_js_function.awk -v fname=zot
#
# Remarks:
#   - If 'fname' is not specified, script will exit with error message and
#     code 1
#   - Function definition to be matched should start on a separate line
#     (no other commands before it, only whitespace allowed)
#   - There also should not be any commands after the end of the function body
#     in the same line as the final closing brace, because they would be
#     removed, too.
#   - The script is NOT executable on purpose, because of shebang issues:
#       a) A fixed path to 'awk' is no good (may vary from system to system):
#          #!/usr/bin/awk -f
#       b) Using the 'env' command like this may yield errors because of "-f":
#          #!/usr/bin/env awk -f

BEGIN {
	if (!fname) {
		print \
			"awk: remove_js_function.awk: no function name specified, " \
			"please use variable 'fname'" \
			> "/dev/stderr"
		exit 1
	}
	fhead="^[[:space:]]*function[[:space:]]+" fname "\\y"
}

# Find function header
$0 ~ fhead {
	# Find begin of function body
	in_body=0
	while (!in_body) {
		(in_body=index($0, "{")) || getline
	}
	# Find end of function body counting curly braces
	brace_count=1
	i=in_body+1
	while (brace_count) {
		pos = match(substr($0, i), "[{}]")
		if (pos) {
			i += pos
			brace_count += (substr($0, i-1, 1)=="{" ? 1 : -1)
			if (!brace_count) next
		}
		else {
			getline
			i=1
		}
	}
}

{ print }
