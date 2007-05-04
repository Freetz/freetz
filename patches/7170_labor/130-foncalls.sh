[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}applying foncalls.patch"

if [ "$DS_TYPE_LABOR_USB" == "y" ] || [ "$DS_TYPE_LABOR_VPN" == "y" ]; then
    modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/foncalls_7170_labor_usb.patch
elif [ "$DS_TYPE_LABOR_ECO" == "y" ]; then
    modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/foncalls_7170_labor_eco.patch
else
    modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/foncalls_7170_labor.patch
fi