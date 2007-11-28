[ "$DS_COPY_MODULES" == "y" ] || return 0

echo1 "copying modules from tk-firmware"
#mv "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio" "${FILESYSTEM_MOD_DIR}/lib/modules/W900V-2.6.13.1-ohio"
#rm -rf "${FILESYSTEM_MOD_DIR}/lib/modules/W900V-2.6.13.1-ohio"
#mkdir -p "${FILESYSTEM_MOD_DIR}/lib/modules/TK-2.6.13.1-ohio"
"$TAR" -c -C "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio" . | "$TAR" -x -C "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio"
