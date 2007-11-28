FN_IMAGE="dl/*-8221.image"
FN_ZIP="dl/*-8221.zip"

FILES1="
usr/lib/mediasrv/ConnectionManager.xml
usr/lib/mediasrv/MediaServerDevDesc-template.xml
usr/lib/mediasrv/mediapath
usr/lib/mediasrv/MediaServerDevDesc.xml
usr/lib/mediasrv/ContentDirectory.xml
sbin/stop_mediasrv
sbin/mediasrv
sbin/start_mediasrv
"
FILES2="
etc/default.Fritz_Box_7170/avm/ConnectionManager.xml
etc/default.Fritz_Box_7170/avm/MediaServerDevDesc-template.xml
etc/default.Fritz_Box_7170/avm/mediapath
etc/default.Fritz_Box_7170/avm/MediaServerDevDesc.xml
etc/default.Fritz_Box_7170/avm/ContentDirectory.xml
"

[ "$DS_PATCH_MEDIASRV" == "y" ] || return 0

TMPDIR="$MOD_DIR/mediasrv"

if [ ! -d $TMPDIR ] ; then
	if [ ! -f $FN_IMAGE ] ; then
		if [ ! -f $FN_ZIP ] ; then
			echo1 "media server patch: neither firmware image nor zip file found"
			exit 1
		fi
		echo1 "media server patch: extracting USB Labor firmware from zip file"
		unzip $FN_ZIP '*.image' -d dl
		if [ ! -f $FN_IMAGE ] ; then
			echo1 "media server patch: could not unpack zip file"
			exit 1
		fi
	fi
	echo1 "media server patch: extracting USB Labor firmware"
	./fwmod -d $TMPDIR -u $FN_IMAGE > /dev/null
fi

echo1 "media server patch: copying files"
for F in $FILES1 ; do
	mkdir -p $FILESYSTEM_MOD_DIR/`dirname $F`
	cp -a $TMPDIR/original/filesystem/$F $FILESYSTEM_MOD_DIR/$F
done
for F in $FILES2 ; do
	TARGETDIRS=`ls -d $FILESYSTEM_MOD_DIR/etc/default.Fritz_Box*/*`
	for D in $TARGETDIRS; do
		cp -a $TMPDIR/original/filesystem/$F $D/`basename $F`
	done
done

echo1 "patching MEDIASRV in rc.init"
if [ -e "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init" ]; then
	sed -i -e "s/MEDIASRV=n/MEDIASRV=y/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
	echo1 "patching isMedia in rc.S"
	sed -i -e "s/isMediaSrv 0/isMediaSrv 1/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
else
	sed -i -e "s/CONFIG_MEDIASRV=n/CONFIG_MEDIASRV=y/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
fi

