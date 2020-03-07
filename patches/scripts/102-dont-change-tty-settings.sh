[ "$FREETZ_AVM_VERSION_06_0X_MIN" == "y" ] || return 0

# freetz launches sysinit without controlling tty (s. patches/scripts/102-add_inittab.sh)
# don't try to set/change tty settings as it won't work

for file in \
  etc/boot.d/core/00-head \
  etc/boot.d/core/head \
  etc/init.d/S01-head \
  ; do
	[ -e "${FILESYSTEM_MOD_DIR}/$file" ] && modsed -r 's,^([ \t]*stty .*),## disabled by freetz: \1,' "${FILESYSTEM_MOD_DIR}/$file"
done

