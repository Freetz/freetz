isFreetzType 7320 && return 0

# Emergency stop switch for execution of debug.cfg
sed -i -r 's#(\. /var/flash/debug\.cfg)#[ "$dbg_off" == "y" ] || \1#g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
# Emergency stop switch for execution of Freetz as a whole
echo '[ "$ds_off" == "y" ] || . /etc/init.d/rc.mod 2>&1 | tee /var/log/mod.log' >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
