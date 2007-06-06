if [ "$DS_COPY_MODULES" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}copying modules from tk-firmware"
	"$TAR" -cf - -C "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio" --exclude=drivers/usb . | "$TAR" -xf - -C "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio"
fi