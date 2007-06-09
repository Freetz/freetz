if [ "$DS_COPY_MODULES" == "y" ]
then
	echo1 "copying modules from tk-firmware"
#	mv "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio" "${FILESYSTEM_MOD_DIR}/lib/modules/W900V-2.6.13.1-ohio"
#	rm -rf "${FILESYSTEM_MOD_DIR}/lib/modules/W900V-2.6.13.1-ohio"
#	mkdir -p "${FILESYSTEM_MOD_DIR}/lib/modules/TK-2.6.13.1-ohio"
	"$TAR" -cf - -C "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio" . | "$TAR" -xf - -C "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio"
fi