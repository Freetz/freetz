[ "$FREETZ_BUSYBOX_UNICODE_SUPPORT" == "y" ] || return 0

echo1 "setting LANG variable to 'en_US.UTF-8'"
echo -e "\nexport LANG='en_US.UTF-8'" >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
