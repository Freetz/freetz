[ "$FREETZ_PACKAGE_SAMBA" == "y" ] || return 0
echo1 "remove AVM samba config"
rm -f "${FILESYSTEM_MOD_DIR}/etc/samba_config.tar"

cat > "${FILESYSTEM_MOD_DIR}/etc/samba_control" << 'EOF'
#!/bin/sh

ICKE=$$
PIDF=/var/run/samba_control.pid

if [ ! -r $PIDF ]; then
	echo $$ > $PIDF
fi
sleep 1
if [ $(ps |grep -v $ICKE|sed 's/^ \+//g'|cut -f1 -d" "|grep $(cat $PIDF)|wc -w) -eq 0 ]; then
	echo $$ > $PIDF
else
	exit
fi

. /etc/term.sh

if [ $# -ge 2 ]; then
	for SHARE in /var/media/ftp/* ; do
		rmdir $SHARE 2>/dev/null
	done
fi

if [ "`pidof smbd`" != "" ]; then
	/etc/init.d/rc.samba restart smbd
else
	/etc/init.d/rc.samba config
fi

rm $PIDF 2>/dev/null

EOF
