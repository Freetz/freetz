#!/bin/bash

if [ "$DS_TYPE_LANG_A_CH" == "y" ]; then
    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/110-rc.S-mknod_7170.a_ch.patch"
else
    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/110-rc.S-mknod_7170.patch"
fi