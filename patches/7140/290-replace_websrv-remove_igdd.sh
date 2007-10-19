#!/bin/bash

echo1 "applying replace websrv / remove igdd patch for 7140"
if [ "$DS_TYPE_LANG_EN" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/290-replace_websrv-remove_igdd_7140_en.patch"
elif [ "$DS_TYPE_LANG_A_CH" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/290-replace_websrv-remove_igdd_7140_a_ch.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/290-replace_websrv-remove_igdd_7140_de.patch"
fi
