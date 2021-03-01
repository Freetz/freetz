[ "$FREETZ_PATCH_WEBIF_FEATURES" == "y" ] || return 0
echo1 "applying webif features"

for i in "${PATCHES_COND_DIR}/800-webif_features/"*.sh; do
	[ -r "$i" ] || continue
	echo2 -l "applying patch file $i" 
	source $i
done

