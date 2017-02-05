[ "$FREETZ_PATCH_GITSHELL_LOGIN_SHELL" == "y" ] || return 0
echo1 "adding git-shell to the list of login shells"
grep -q "^/usr/bin/git-shell$" "${FILESYSTEM_MOD_DIR}/etc/shells" >/dev/null 2>&1 || ( echo "/usr/bin/git-shell" >> "${FILESYSTEM_MOD_DIR}/etc/shells" )
