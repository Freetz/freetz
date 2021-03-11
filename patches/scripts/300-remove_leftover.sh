[ "$FREETZ_REMOVE_LEFTOVER" == "y" ] || return 0
echo1 "applying leftover files"

for i in "${PATCHES_COND_DIR}/300-remove_leftover/"*.sh; do
	[ -r "$i" ] || continue
	echo2 -l "applying patch file $i"
	source $i
done

