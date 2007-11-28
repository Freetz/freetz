rm_files()
{
	for file in $1; do
	echo2 "$file"
	rm -rf "$file"
	done
}

[ "$DS_REMOVE_DSLD" == "y" ] || return 0

echo1 "removing dsld files"
rm_files "$(find ${FILESYSTEM_MOD_DIR}/sbin -name '*dsld*')"
rm_files "$(find ${FILESYSTEM_MOD_DIR}/lib/modules -name dsld)"
if [ -e "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init" ]; then
	sed -i -e "s/DSL=y/DSL=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
else
	sed -i -e "s/CONFIG_DSL=y/CONFIG_DSL=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
fi

