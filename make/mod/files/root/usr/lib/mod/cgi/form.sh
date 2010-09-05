#
# Easy setting of *_chk and *_sel variables for <input> elements
# depending on configuration variables.
#
#	swap_auto_chk=''
#	swap_man_chk=''
#	if [ "$MOD_SWAP" = "yes" ]; then
#		swap_auto_chk=' checked'
#	else
#		swap_man_chk=' checked'
#	fi
#
# is equivalent to
#
#	check "$MOD_SWAP" yes:swap_auto "*":swap_man
#
_check() {
	local input=$1 alt key val var found=false; shift
	for alt; do
		key=${alt%%:*}; val=${alt#*:}
		var=${val:-$key}${suffix}
		if ! $found; then
			case $input in
				$key) eval "$var=\$checked"; found=true; continue ;;
			esac
		fi
		eval "$var="
	done
}
check()  suffix=_chk checked=" checked" _check "$@"
select() suffix=_sel checked=" selected" _check "$@"
