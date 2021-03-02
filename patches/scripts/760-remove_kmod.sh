[ "$FREETZ_REMOVE_KMOD" == "y" ] || return 0
echo1 "removing kmod and links to it"

rm_files $(find -L "${FILESYSTEM_MOD_DIR}/" -samefile "${FILESYSTEM_MOD_DIR}/usr/bin/kmod")

