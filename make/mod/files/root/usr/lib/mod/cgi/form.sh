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

# Print a radiogroup
#   $1: Name of the variable
#   $2: current value, selects checked entry
#   $3: Heading, any HTML text
#   $4..$n: Liste of radio entries as val:id:text
#     val: value for this entry, leading '+' for default entry
#     id: HTML id for this entry, can be empty
#     text: HTML text for this entry
cgi_print_radiogroup()
{
    local name=$1
    local value=$2
    local head=$3
    local nr nr_chk val chk id text
    shift 3

    echo "<p>"
    echo "$head"
    nr_chk=0
    nr=1
    for i; do
	val="${i%%:*}"
	if [ "$val" != ${val#+} ]; then
	    nr_chk=$nr
	fi
	if [ "$value" = "$val" ]; then
	    nr_chk=$nr
	    break;
	fi
	nr=$((nr+1))
    done
    nr=1
    for i; do
	val="${i%%:*}"
	i="${i#*:}"
	id="${i%%:*}"
	i="${i#*:}"
	text=$i
	val=${val#+}
	if [ -z "$id" ]; then
	    id="${name}_${val}"
	fi
	if [ $nr = $nr_chk ]; then
	    chk=" checked"
	else
	    chk=
	fi
	echo "<input id=\"$id\" type=\"radio\" name=\"$name\" value=\"$val\"$chk><label for=\"$id\">$text</label>"
	nr=$((nr+1))
    done
    echo "</p>"
}
