if [ -z "$FIRMWARE2" ]
then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "Copying libgcc..."
cp ${DIR}/.tk/original/filesystem/lib/libgcc* ${FILESYSTEM_MOD_DIR}/lib/
