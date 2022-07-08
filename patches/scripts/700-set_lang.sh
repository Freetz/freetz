[ "$FREETZ_BUSYBOX_UNICODE_SUPPORT" == "y" ] && MyLANG='en_US.UTF-8' || MyLANG='C'
echo1 "setting LANG variable to '$MyLANG'"

echo -e "\nexport LANG='$MyLANG'" >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

