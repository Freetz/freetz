#
# freetz launches sysinit without controlling tty (s. patches/scripts/102-add_inittab.sh)
# don't try to set/change tty settings as it won't work
#

if [ "$FREETZ_AVM_VERSION_06_XX_MIN" == "y" ]; then
	modsed -r 's,^([ \t]*stty .*),## disabled by freetz: \1,' "${FILESYSTEM_MOD_DIR}/etc/init.d/S01-head"
fi
