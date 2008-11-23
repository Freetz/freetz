# process only when libfreetz is not selected
[ "$FREETZ_LIB_libfreetz" == "n" ] || return 0

echo1 "rename ctlmgr"

mkdir "$FILESYSTEM_MOD_DIR/usr/bin/avm" 2>/dev/null
mv "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr" "$FILESYSTEM_MOD_DIR/usr/bin/avm/ctlmgr"
touch "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr"
cat << 'EOF' >> "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr"
#!/bin/sh
export TMP_PASSWD_FILE="/var/tmp/passwd.temp.ctlmgr"
export PASSWD_FILE="/etc/passwd"
export CTLMGR_BINARY="/usr/bin/avm/ctlmgr"
touch $TMP_PASSWD_FILE
cat $PASSWD_FILE > $TMP_PASSWD_FILE
$CTLMGR_BINARY "$@" &
cat $TMP_PASSWD_FILE |grep -v "^root:"|grep -v "^ftpuser:">>$PASSWD_FILE
rm -f $TMP_PASSWD_FILE
EOF

chmod 755 "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr"
