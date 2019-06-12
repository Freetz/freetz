[ "$FREETZ_REMOVE_LANGUAGES" == "y" ] || return 0
echo1 "removing language files"

for lang in de en es fr it nl pl; do
	[ "$(eval echo "\$FREETZ_REMOVE_LANGUAGE_$lang")" != "y" ] || rm_files "${FILESYSTEM_MOD_DIR}/etc/htmltext_${lang}.db"
done

