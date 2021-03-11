[ "$FREETZ_PATCH_VOL_COUNTER" == "y" ] || return 0
echo1 "adding volume counter support to the web-ui"

vol_counter_sed=$(mktemp -q -t "${FREETZ_TYPE_PREFIX}-${FREETZ_TYPE_PREFIX_SERIES_SUBDIR}-vol-counter-XXXXXX.sed")
vol_counter_patch=$(mktemp -q -t "${FREETZ_TYPE_PREFIX}-${FREETZ_TYPE_PREFIX_SERIES_SUBDIR}-vol-counter-XXXXXX.patch")

# generate sed-script for text messages missing in the htmltext_de.db of the target box, for that
# 1. replace German umlauts and ß with their html counterparts
# 2. escape regexp backreference symbol (&) and the separator symbol (#) we use in our sed script
# 3. convert vol-counter-htmltext_de.db.txt to sed script
cat "${PATCHES_COND_DIR}/241-restore_vol_counter/${FREETZ_TYPE_PREFIX}-${FREETZ_TYPE_PREFIX_SERIES_SUBDIR}-vol-counter-htmltext_de.db.txt" \
| sed -e '
s#'$'\xc3\x84''#\&Auml;#g
s#'$'\xc3\xa4''#\&auml;#g
s#'$'\xc3\x96''#\&Ouml;#g
s#'$'\xc3\xb6''#\&ouml;#g
s#'$'\xc3\x9c''#\&Uuml;#g
s#'$'\xc3\xbc''#\&uuml;#g
s#'$'\xc3\x9f''#\&szlig;#g
' \
| sed -r -e 's,([&#]),\\\1,g' \
| sed -r -e 's,^([0-9]+:[0-9]+)\t(.*)$,s#[{][?]\1[?][}]#\2#g,' \
> "${vol_counter_sed}"

for oem in $(supported_brandings) all; do
	www_oem="${FILESYSTEM_MOD_DIR}/usr/www/${oem}"
	[ -d "${www_oem}" -a ! -L "${www_oem}" ] || continue

	# replace htmltext_de.db references {?XXX:XXX?} in the patch with their text values
	cat "${PATCHES_COND_DIR}/241-restore_vol_counter/${FREETZ_TYPE_PREFIX}-${FREETZ_TYPE_PREFIX_SERIES_SUBDIR}-vol-counter.patch" \
	| sed -f "${vol_counter_sed}" \
	| sed -r -e 's,^(([+]{3}|-{3}) usr/www/)all/,\1'"${oem}"'/,' \
	> "${vol_counter_patch}"

	# apply generated patch
	modpatch "$FILESYSTEM_MOD_DIR" "${vol_counter_patch}"
done

# remove temporary files
rm -f "${vol_counter_sed}" "${vol_counter_patch}"

# set CONFIG_VOL_COUNTER to "y"
echo1 "enabling volume counter support in /etc/init.d/rc.conf"
modsed 's,CONFIG_VOL_COUNTER=.*$,CONFIG_VOL_COUNTER="y",' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" 'CONFIG_VOL_COUNTER="y"$'

