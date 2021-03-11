[ "$FREETZ_TYPE_ALIEN_HARDWARE" == "y" ] || return 0
echo1 "applying alien files"

for i in "${PATCHES_COND_DIR}/100-aliens/scripts/"*.sh; do
	[ -r "$i" ] || continue
	echo2 -l "applying patch file $i" 
	source $i
done

