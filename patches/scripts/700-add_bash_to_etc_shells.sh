[ "$FREETZ_PATCH_BASH_LOGIN_SHELL" == "y" ] || return 0
echo1 "adding bash to the list of login shells"
grep -q "^/bin/bash$" "${FILESYSTEM_MOD_DIR}/etc/shells" >/dev/null 2>&1 || ( echo "/bin/bash" >> "${FILESYSTEM_MOD_DIR}/etc/shells" )
