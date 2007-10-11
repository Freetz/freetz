if [ "$DS_COPY_MODULES" == "y" ]
then
	echo1 "copying modules from tk-firmware"
	"$TAR" -c -C "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio" --exclude=drivers/usb . | "$TAR" -x -C "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio"
fi