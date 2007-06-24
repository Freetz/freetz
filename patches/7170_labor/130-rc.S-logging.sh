echo1 "applying rc.S-logging.patch"
if [ "$DS_TYPE_LABOR_PHONE" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/rc.S-logging_7170_labor_phone.patch
else
	modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/rc.S-logging_7170_labor.patch
fi