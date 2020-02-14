[ "$FREETZ_AVM_VERSION_06_0X_MIN" == "y" ] || return 0

# freetz launches sysinit without controlling tty (s. patches/scripts/102-add_inittab.sh)
# don't try to set/change tty settings as it won't work

[ -n "$SYSTEMD_CORE_MOD_DIR" ] && file="etc/boot.d/core/00-head" || file="etc/init.d/S01-head"
[ -e "${FILESYSTEM_MOD_DIR}/$file" ] && modsed -r 's,^([ \t]*stty .*),## disabled by freetz: \1,' "${FILESYSTEM_MOD_DIR}/$file" 'disabled by freetz'

